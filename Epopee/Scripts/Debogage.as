package  {
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.text.TextField;
	import flash.utils.getQualifiedClassName;
	import flash.geom.Point;

	/*******************************************************************************
	ATTENTION: Pour le moment cette classe ne doit pas être modifiée. (PAS DU TOUT!)
	*******************************************************************************/	
	
	public class Debogage extends MovieClip {
		// CONSTRUCTEUR
		private var _modeDebogage:Boolean=false;	
		private var _accesDebogage:Boolean=false;
		private var _phaseEntreeMDP:Boolean=false;	
		private var _MDP:String="tim";	
		private var _lettresEntreesMDP:String="";	
		
		private var _txtInfoDebogage:TextField = new TextField();
		private var _marge:uint = 10;
		private var _txtAffiche:String="";
		private var _memTxtAffiche:String="";
		private var _miseAJourAuto:Boolean = true;
		
		private var _jeu:MovieClip;

		public function Debogage(jeu) { 
			_jeu = jeu; // initialisation de la référence à jeu (requis avant init)
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/******************************************************************************
		Fonction init
		******************************************************************************/		
		private function init(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, nettoyer);
			
			// ajout préparation d'un champ texte:
			_txtInfoDebogage.x = stage.stageWidth + _marge;
			_txtInfoDebogage.y = _marge;
			with(_txtInfoDebogage){ wordWrap = true; width = 250; }
			changerTxt();
			addChild(_txtInfoDebogage);
			if(_miseAJourAuto){ addEventListener(Event.ENTER_FRAME, changerTxt); }
		} //init
		
		/******************************************************************************
		Fonction nettoyer
		******************************************************************************/		
		private function nettoyer(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, nettoyer);
			if(_miseAJourAuto){ removeEventListener(Event.ENTER_FRAME, changerTxt); }
			addEventListener(Event.ADDED_TO_STAGE, init); 
			removeChild(_txtInfoDebogage);
		} //nettoyer
		
		/******************************************************************************
		Fonction frappeClavierDebogage
		  Elle est exécutée quand la classe jeu relaie la frappe.
		******************************************************************************/
		public function frappeClavierDebogage(e:KeyboardEvent):Boolean {
			var touche:uint = e.keyCode;
			
			if(_phaseEntreeMDP){
				var lettre:String = String.fromCharCode(e.charCode);
				verifierMDP(lettre);
				return true; //puisqu'on retourne true, _jeu ne fera rien de plus
				//lorsque la phase d'entrée est activée, les touches ne sont pas traitées davantage par le débogage
			} else if((e.ctrlKey && e.shiftKey)){
				
				if(touche==Keyboard.D){ // «ctrl+shift+D» ...
					
					if(_phaseEntreeMDP==false && _accesDebogage==false){
						log("Début de la séquence d'entrée du mdp.", 2);
						_phaseEntreeMDP=true;
						return true; //puisqu'on retourne true, _jeu ne fera rien de plus
					} else if(_accesDebogage){
						_modeDebogage=!_modeDebogage; log("DEBOGAGE="+_modeDebogage, 2);
						if(_modeDebogage){ _jeu.addChild(this); }else{ _jeu.removeChild(this); }; 
						return true; //puisqu'on retourne true, _jeu ne fera rien de plus
					} //if+else
					
				} else if( _modeDebogage ){
					var perso:Perso;
					switch (touche) {
						case Keyboard.NUMBER_5 : for each( perso in _jeu.getTPersos() ){ perso.superForceDebogage(); }; break; // «ctrl+shift+5» + DÉBOGAGE ...
						case Keyboard.NUMBER_6 : for each( perso in _jeu.getTPersos() ){ perso.mauvietteDebogage(); }; break; // «ctrl+shift+6» + DÉBOGAGE ...
						case Keyboard.B : _jeu.amorcerCombat(); break; // «ctrl+shift+b» + DÉBOGAGE déclenche une bataille immédiate
						case Keyboard.S : 
							_jeu.setMusiqueOn( !_jeu.getMusiqueOn() ); 
							if( !_jeu.getMusiqueOn() ){
								_jeu.arreterMusique(); 
							} else {
								_jeu.jouerMusique( "", true );
							}; break; // «ctrl+shift+S» + DÉBOGAGE désactive ou active la musique
					} //switch
					
					if( _jeu.getEcranDeJeu() is Tableau && _jeu.getEstEnDialogue()==false ){
						switch (touche) {
							case Keyboard.NUMBER_2 : _jeu.ajouterPersoDebogage("pnjNova_mc"); break; // «ctrl+shift+2» + DÉBOGAGE ajoute Nova pour tests
							case Keyboard.NUMBER_3 : _jeu.ajouterPersoDebogage("pnjLucem_mc"); break; // «ctrl+shift+3» + DÉBOGAGE ajoute Lucem pour tests
							case Keyboard.NUMBER_4 : _jeu.ajouterPersoDebogage("pnjFortis_mc"); break; // «ctrl+shift+4» + DÉBOGAGE ajoute Fortis  pour tests
							case Keyboard.NUMBER_8 : _jeu.ajouterObjet("Patate"); break; // «ctrl+shift+8» + DÉBOGAGE ajoute une patate
							case Keyboard.P : _jeu.montrerCtrlPad(true); break; // «ctrl+shift+p» + DÉBOGAGE affiche le ctrlPad
							case Keyboard.T : testerIntegration(); break; // «ctrl+shift+t» + DÉBOGAGE teste tous les tableaux pour générer un rapport
						} //switch
					} //if	(c'est un tableau, pas en dialogue)
					
					return true; //puisqu'on retourne true, _jeu ne fera rien de plus
				
				}  //if(D) +else if(_modeDebogage)
				
			} //if(_phaseEntreeMDP) + else if(CTRL+SHIFT)
			return false; //puisqu'on retourne false, _jeu fera sa propre analyse
		} //frappeClavierDebogage
		
		/******************************************************************************
		Fonction verifierMDP
		******************************************************************************/
		private function verifierMDP(lettre:String):void{
			_lettresEntreesMDP += lettre.toLowerCase(); //le mot de passe est insensible à la casse!
			if(_lettresEntreesMDP == _MDP.slice(0, _lettresEntreesMDP.length)){
				//jusqu'ici le mdp est identique
				if(_lettresEntreesMDP == _MDP){
					//le mdp a été entré en entier
					_phaseEntreeMDP=false;
					_accesDebogage=true;
					log("L'ACCES AU DÉBOGAGE EST MAINTENANT DÉVÉROUILLÉ. ACTIVATION IMMÉDIATE.", 2);
					_modeDebogage=true; 
					_jeu.addChild(this);
				} //if
			} else {
				_phaseEntreeMDP=false;
				_lettresEntreesMDP = "";
				log("Erreur de mdp: fin de la séquence d'entrée.", 2);
			} //if+else
		} //verifierMDP
		
		/******************************************************************************
		Fonction testerIntegration
		  Elle teste tous les tableaux pour vérifier les noms des principales instances
		  ainsi que portes et portails.
		******************************************************************************/
		public function testerIntegration():void{
			//préparation des variables requises:
			var txtSepar:String =   "*******************************************************************************\n";
			var txtRapport:String = txtSepar+"***** RAPPORT DU TEST DES NIVEAUX ET DE LEURS CONTENUS ************************\n"+txtSepar;
			var txtEtape:String;
			var txtErreur:String;
			var tTxtErreurs:Array = [];
			var nomTableau:String;
			var nomEnfant:String;
			var ecranEnCours:MovieClip;
			var memNomEcran:String = getQualifiedClassName( _jeu.getEcranDeJeu() ).slice(3); //identification du nom du tableau (en supprimant «Tab» au début);
			var memPosPerso:Point = _jeu.getTPersos()[0].getPosPerso();
			var unEnfant:DisplayObject;
			var tTabDepartDestin:Array = [];
			
			//début du test:
			try{
				for each(nomTableau in _jeu.getTTableaux()){ //boucle sur tous les tableaux déclarés
					var txtEtape:String = "Début du test du tableau "+nomTableau
					log(txtEtape, 2);
					txtRapport += txtEtape += "\n";
					
					try{
						_jeu.changerEcranJeu(nomTableau);
						ecranEnCours = _jeu.getEcranDeJeu();
					} catch(e:Error){
						txtErreur = "ERREUR! Impossible d'accéder au tableau "+nomTableau;
						tTxtErreurs.push(txtErreur);
					} //try+catch 
					
					try{
						var tTeleports:Array = [];
						var tPortes:Array = [];
						var tPNJs:Array = [];
						var tObjets:Array = [];
						var tObstacles:Array = [];
						
						for(var i=0; i<ecranEnCours.numChildren-1; i++){
							unEnfant = ecranEnCours.getChildAt(i);
							nomEnfant = unEnfant.name;
							if(unEnfant is Teleport){tTeleports.push(unEnfant);}
							else if(unEnfant is Porte){
								tPortes.push(unEnfant);
								var nomTabDepart:String = getQualifiedClassName( ecranEnCours ).slice(3); //le nom du tableau en cours
								var nomTabDestin:String = unEnfant.name.split("_")[1]; //le nom du tableau à atteindre
								tTabDepartDestin.push([nomTabDepart, nomTabDestin]); //servira ensuite pour vérifier l'existence des portails
							} else if(unEnfant is PNJ){tPNJs.push(unEnfant);}
							else if(unEnfant is Objet){tObjets.push(unEnfant);}
							else if(unEnfant is Obstacle){tObstacles.push(unEnfant);}
						} //for
						
							txtEtape = "  Contenu du tableau "+nomTableau+": \n";
							txtEtape += "   • "+tTeleports.length  +" téléport(s) : [" +extraireNoms(tTeleports)+"]\n";
							txtEtape += "   • "+tPortes.length     +" porte(s) : ["    +extraireNoms(tPortes)+"]\n";
							txtEtape += "   • "+tPNJs.length       +" PNJ(s) : ["      +extraireNoms(tPNJs)+"]\n";
							txtEtape += "   • "+tObjets.length     +" objet(s) : ["    +extraireNoms(tObjets)+"]\n";
							txtEtape += "   • "+tObstacles.length  +" obstacle(s) \n";
							txtRapport += txtEtape += "\n";
					} catch(e:Error){
						throw(new Error("Une erreur est survenue en cherchant les enfants du tableau."));
					} //try+catch
					
					//test des noms des instances
					for each( var tArray:Array in [tPortes, tPNJs, tObjets] ){
						for each( var unClip:MovieClip in tArray ){
							if( unClip.verifierSiValide()==false ){ //ce clip a échoué le test
								txtErreur = "Échec du test du clip «"+unClip.name+"»";
								txtErreur += " ("+getQualifiedClassName( unClip )+")";
								txtErreur += " dans le tableau "+nomTableau;
								txtErreur += " (x="+unClip.x+", y="+unClip.y+")";
								txtErreur += " *";
								tTxtErreurs.push(txtErreur);
							} //if clip est valide
						} //for each unClip...
					} //for each tArray...
				} //for each nomTableau... (1ère boucle)
				
				for each(nomTableau in _jeu.getTTableaux()){ //nouvelle boucle sur tous les tableaux déclarés
					//test de l'existence des téléports correspondants aux portes des tableaux
					try{
						_jeu.changerEcranJeu(nomTableau);
						ecranEnCours = _jeu.getEcranDeJeu();
					} catch(e:Error){
						//inutile de stocker un message d'erreur, car c'est la 2e boucle identique...
						log("ERREUR! Impossible d'accéder au tableau "+nomTableau, 3);
					} //try+catch
					for each(var t:Array in tTabDepartDestin){
						if(t[1]==nomTableau){ 
							//la destination était le tableau en cours, donc cherchons le teleport requis:
							var nomTabDepart:String = t[0]; //récupération du nom du tableau de départ
							var nomTeleport:String = "teleport_"+ nomTabDepart +"_mc"; //creation du nom du teleport
							
							try{ 
								var teleport_mc:MovieClip = MovieClip(ecranEnCours.getChildByName(nomTeleport)); 
								var testX:Number = teleport_mc.x; //l'accès à la propriété x est impossible si le clip est inexistant
							} catch(e:Error){ 
								//il n'y a probablement pas de teleport correspondant au nom demandee
								txtErreur = "Erreur de teleport! Dans le tableau «"+t[1];
								txtErreur += "» il n'y a pas de téléport nommé «"+nomTeleport+"» (requis par une porte...)";
								tTxtErreurs.push(txtErreur);
							} //try+catch
						} //if
					} //for each t...
				} //for each nomTableau... (2e boucle)
			} catch(e:Error){
				throw(new Error("Une erreur inattendue est survenue dans le processus de test.]"));
			} //try+catch principal
			
			_jeu.changerEcranJeu(memNomEcran); //retour au tableau initial (celui avant les tests)
			_jeu.getTPersos()[0].placerCorps(memPosPerso); //on rétabli la position initiale du perso (position d'avant les tests)
			
			if(tTxtErreurs.length>0){ 
				txtRapport += "Fin du test. Nombre d'erreur(s): "+tTxtErreurs.length+"\n";
				txtRapport += " >>> "+ tTxtErreurs.join("\n >>> ")+"\n";
				txtRapport += " * Vérifiez le nom de l'instance (examinez la fonction «verifierSiValide» dans la classe du clip pour plus de détails)";
			} else {
				txtRapport += "Fin du test. Aucune erreur!\n";
			} //if+else
			log("\n"+txtRapport +"\n\n"+txtSepar+txtSepar, 2);
		} //testerIntegration
		
		/******************************************************************************
		Fonction extraireNoms
		******************************************************************************/		
		private function extraireNoms(tClips:Array):Array{
			var tNoms:Array = [];
			for each(var unClip:MovieClip in tClips){ tNoms.push(unClip.name); }
			tNoms.sort();
			return tNoms;
		} //extraireNoms
		
		/******************************************************************************
		Fonction changerTxt
		******************************************************************************/		
		private function changerTxt(e:Event=null):void {
			_txtAffiche = _jeu.getTxtVersion() + "\n\n" + _jeu.getEcranDeJeu() + "\n\n" + _jeu.getTPersos() + "\n\n" + _jeu.getTObjets();
			if(_txtAffiche != _memTxtAffiche){
				_memTxtAffiche = _txtAffiche;
				_txtInfoDebogage.text = _txtAffiche;
			} //if
		} //changerTxt 
		
	} //class
} //package