package {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;

	public class Porte extends Obstacle {
		private var _tab:MovieClip;
		private var _jeu:MovieClip;
		
		public function Porte() {
			// CONSTRUCTEUR
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/******************************************************************************
		Fonction init
		******************************************************************************/		
		private function init(e:Event):void {
			// initialisation des références aux 2 parents:
			_tab = MovieClip(parent);
			_jeu = MovieClip(parent.parent);

			gererVisibilite(); //masque la porte à l'utilisateur 
			
			stage.addEventListener("changementVisibilite", gererVisibilite, true); // pour débogage, ne pas enlever cette ligne
			addEventListener(Event.REMOVED_FROM_STAGE, nettoyer);
		} //init

		/******************************************************************************
		Fonction interagir
		 Elle permet de déclencher l'interaction liée à la porte rencontrée. 
		 (Cette version de la fonction a préséance sur la version de la classe Obstacle.)
		******************************************************************************/
		override public function interagir(modeTest:Boolean=false):String {
			var nomPorte:String = this.name;
			var nomTableau:String = getQualifiedClassName(_tab).slice(3); //identification du nom du tableau (en supprimant «Tab» au début)
			log("rencontre avec la porte «"+nomPorte+"» dans le tableau «"+nomTableau+"»", 2);
			var nomDestination:String = nomPorte.split("_")[1]; //extraction du 2e item, c'est-à-dire le nom de la destination
			
			if( (_jeu.verifierTableau(nomDestination)==false) ){ //false si la destination n'est pas connue de _jeu...
				
				if( modeTest ){ return "Erreur"; } //si appelé par la fn verifierSiValide(), on quitte avec erreur
				
				log("BOGUE: Tableau de destination inconnu... Allons voir maman pour pleurer!", 2);
				nomTableau="Village"; //origine par défaut
				nomDestination="MaisonMaman"; //destination par défaut
			} //if
			
			var nomClipTeleport:String = "teleport_"+ nomTableau +"_mc"; //creation du nom du teleport
			
			if( modeTest ){ return "Ok"; } //si appelé par la fn verifierSiValide(), on quitte sans erreur
				
			//changerEcranJeu doit recevoir le nom du tableau de destination et le nom d'instance du clip teleport (pour déterminer la position d'arrivée X, Y):
			_jeu.changerEcranJeu(nomDestination, nomClipTeleport);
			
			return "ChangementDeTableau";
		} //interagir
		
		/******************************************************************************
		Fonction gererVisibilite
		******************************************************************************/		
		private function gererVisibilite(e:Event=null):void{
			if( _jeu.getZonesTechniquesVisibles() ){
				this.visible = true; //la zone sera visible, pour fin de débogage
			} else {
				this.visible = false; //le portail doit être invisible pour l'utilisateur
			} //if+else
		} //gererVisibilite

		/******************************************************************************
		Fonction nettoyer
		******************************************************************************/		
		private function nettoyer(e:Event):void{
			stage.removeEventListener("changementVisibilite", gererVisibilite);
		} //nettoyer
		
		/******************************************************************************
		*******************     FONCTIONS DE TESTS AUTOMATISÉS     ********************
		******************************************************************************/
		public function verifierSiValide():Boolean{ 
			var resultat:Boolean = true; //le test est valide, jusqu'à preuve du contraire!
			
			//### Les règles à tester pour valider le nom de l'instance ###
			
			var tPartiesDuNom = name.split("_"); //segmentation du nom
			
			//#1. la nom doit débuter par "porte_":
			if( tPartiesDuNom[0]!="porte" ){ resultat = false; } //c'est un échec si le nom ne débute pas comme prévu...
			
			//#2. le nom doit se terminer par "_mc"
			if( tPartiesDuNom[2]!="mc"){ resultat = false; } //c'est un échec si le nom ne se termine pas comme prévu...
			
			//#3. la porte doit avoir une destination valide 
			var modeDeTest:Boolean = true;
			if( interagir(modeDeTest)=="Erreur" ){ resultat = false; } //c'est un échec si la destination n'est pas valide...
			
			return resultat;
		} //verifierSiValide

	} //class
} //package