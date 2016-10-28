package {
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.events.Event;
    import flash.geom.Point;
	
	public class Tableau extends MovieClip {
		private var _tPersos:Array;
		private var _tObstacles:Array = [];
		
		private var _jeu:MovieClip;

		public function Tableau(){ 
			// CONSTRUCTEUR
			// Note: pas de paramètres ici, pcq Flash ne permet pas de passer des paramètres 
			// au constructeur d'une classe générée automatiquement (ex. TabVillage)
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/******************************************************************************
		Fonction initParam
		******************************************************************************/		
		public function initParam(tPersos:Array, nomTeleport:String){
			_tPersos = tPersos;
			var posPerso:Point;
			if(nomTeleport == null){
				posPerso = _jeu.getMemPosPerso(); // le MC du perso doit être replacé à son ancienne position
			} else {
				try{ 
					var teleport_mc:MovieClip = MovieClip(getChildByName(nomTeleport)); 
					posPerso = new Point(teleport_mc.x, teleport_mc.y);
					log("Teleport = "+teleport_mc, 2);
				} catch(e:Error){ 
					log("BOGUE: Teleport invalide: "+nomTeleport+". ("+e+")", 2);
					posPerso = new Point(640, 360);
				} //try+catch
			} //if+else
			log("->->->"+posPerso,2);
			addChild(_tPersos[0]);//ajout du perso
			_tPersos[0].placerCorps(posPerso);//ajout du MC, à la position x, y souhaitée
			
			//MÉCANIQUE INITIALE D'ORDONNANCEMENT DES CLIPS:
			var tElements:Array = _tObstacles.concat([]) //tElements est donc une COPIE de _tObstacles
			tElements.sortOn("y", Array.NUMERIC);
			for each(var unClip:MovieClip in tElements){ addChild(unClip); } //chaque obstacle est (ré-)ajouté au tableau, en ordre de leur pos y
			
			placerSandwichPerso();
		} //initParam
		
		/******************************************************************************
		Fonction init
		******************************************************************************/		
		private function init(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_jeu = MovieClip(parent); // initialisation de la référence du parent
			addEventListener(Event.REMOVED_FROM_STAGE, nettoyer)
		} //init
		
		/******************************************************************************
		Fonction nettoyer
		******************************************************************************/		
		public function nettoyer(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, nettoyer);
			log("MÉNAGE DU NIVEAU", 3);
		} //nettoyer
		
		/******************************************************************************
		Fonction listerObstacles
		  Elle permet d'obtenir une trace de tous les obstacles du tableau (pour débogage).
		******************************************************************************/
		public function listerObstacles():void {
			log(_tObstacles, 4);
			for each (var obstacle in _tObstacles) {
				log("position x, y: "+obstacle.x+", "+obstacle.y, 4);
			} //for
		} //listerObstacles

		/******************************************************************************
		Fonction ajouterObstacle
		  Elle permet d'ajouter un élément à la liste des obstacles du tableau.
		******************************************************************************/
		public function ajouterObstacle(unObstacle:MovieClip):void {
			_tObstacles.push(unObstacle);
			listerObstacles(); //pour déboguer seulement!
		} //ajouterObstacle

		/******************************************************************************
		Fonction deplacerJoueur
		  Elle prépare le mouvement du perso principal lorsque le joueur appuie 
		  sur une touche de déplacement, mais il faut d'abord vérifier si c'est permis.
		  Elle reçoit la direction en x et en y où aller
		******************************************************************************/
		public function deplacerJoueur(perso:Perso, dirX:Number, dirY:Number):void {
			log("Déplacement souhaité en x = "+dirX+" & en y = "+dirY, 3);
			if(_jeu.getEstEnDialogue() == false){
				var newPosX:Number;
				var newPosY:Number;
				var posValide:Boolean = true;
				var posPerso:Point = perso.getPosPerso();
	
				newPosX = posPerso.x + dirX;
				newPosY = posPerso.y + dirY;
				var leClip:MovieClip;
				for (var i=0; i<_tObstacles.length; i++) {
					leClip = _tObstacles[i].getZoneCollision();
					if(leClip.hitTestPoint(newPosX,newPosY,true)) {
						var resultat:String = _tObstacles[i].interagir()
						if(resultat == "ChangementDeTableau") {
							return; //tout doit s'arrêter (boucle et fonction) pour éviter un message d'erreur
						} else if(resultat == "Dialogue") {
							break;
						} else if(resultat == "Absent") {
							break;
						} else if(resultat == "") {
							// il n'y a pas d'interaction, mais c'est un obstacle qui doit bloquer le passage:
							posValide = false; break;
						} else {
							// la gestion de cette interaction ne se produit pas ici, le héros peut s'avancer
						} //if+else if+else
					} //if hitTest détecté
				} //for
	
				//si la position est valide:
				if(posValide) {
					var direction:String;
					if(dirX<=0){
						direction = "Gauche";
					} else {
						direction = "Droite";
					} //if+else
					perso.jouerAnim(direction);
					perso.placerCorps(new Point(newPosX, newPosY)); // c'est le perso qui se place lui-même
				} else {
					log("passage impossible...", 2);
					arreterJoueur(perso);
				} //if+else position valide
				
				placerSandwichPerso();
				
				_jeu.verifierSiCombat();
			} //if n'est pas en dialogue
		} //deplacerJoueur
		
		/******************************************************************************
		Fonction arreterJoueur
		  Arrête l'animation du personnage
		******************************************************************************/
		public function arreterJoueur(perso:Perso):void {
			perso.stop();
		}
		
		/******************************************************************************
		Fonction placerSandwichPerso
		  Réordonne tous les éléments interactifs du tableau (obstacles, objets, pnjs, perso)
		  afin de créer l'effet de profondeur au fil des déplacements du joueur
		******************************************************************************/		
		private function placerSandwichPerso():void{
			//MÉCANIQUE D'ORDONNANCEMENT DES CLIPS:
			var tElements:Array = _tObstacles.concat([]); //tElements est donc une COPIE de _tObstacles
			for(var i:uint=0; i<_tPersos.length; i++){
				if(_tPersos[i].parent==this){
					//ce perso est un enfant du tableau, il doit être placé dans le sandwich:
					tElements.push(_tPersos[i]);
				} else {
					//ce perso existe, mais il n'est pas visible dans le tableau...
				}//if+else
			}//for
			tElements.sortOn("y", Array.NUMERIC);
			
			var unClip:MovieClip;
			for (var j:uint=0; j<tElements.length; j++){
				unClip = tElements[j];
				if(_tPersos.indexOf(unClip)>=0){
					//c'est un perso, il faut vérifier sa place dans le sandwich
					var indexCiblePerso:uint; //l'index visé du perso
					var indexActPerso:uint;   //l'index actuel du perso
					indexActPerso = getChildIndex(unClip);
					if(j==0){
						//si j vaut 0, le perso a le plus grand y du lot
						var indexElementAuDessus = getChildIndex(tElements[1]);
						if(indexActPerso<indexElementAuDessus){
							indexCiblePerso = indexElementAuDessus -1; 
						} else {
							//le perso va prendre la place de l'autre (et l'index de cet autre sera changé à cause du décallage)
							indexCiblePerso = indexElementAuDessus;
						}//if+else
					} else {
						var indexElementAuDessous = getChildIndex(tElements[j-1]);
						if(indexActPerso<indexElementAuDessous){
							//le perso va prendre la place de l'autre (et l'index de cet autre sera changé à cause du décallage)
							indexCiblePerso = indexElementAuDessous; 
						} else {
							indexCiblePerso = indexElementAuDessous+1;
						}//if+else
					}//if+else
					
					//Pour débogage de cette mécanique complexe:
					/* var txt:String = "";
					for(var k:uint; k<tElements.length;k++){  txt += tElements[k]+" k="+k+" y="+tElements[k].y+" idx="+getChildIndex(tElements[k])+" ; "  }
					log(txt,2); log(unClip+" sera maintenant à l'index "+indexCiblePerso,2); */
					
					if(indexCiblePerso!=indexActPerso){
						addChildAt(unClip,indexCiblePerso); //au besoin, le perso est replacé dans le sandwich!
					}//if
				}//if
			}//for
		}//placerSandwichPerso
		
	} //class
} //package