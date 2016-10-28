package {
	import flash.display.MovieClip;
	import flash.events.Event;

	public class Objet extends Obstacle {
		private var _absence:Boolean;
		private var _tab:MovieClip;
		private var _jeu:MovieClip;
		
		private var _REPLIQUE:uint=0;
		private var _COMBAT:uint=1;
		private var _OBJET:uint=2;
		private var _EQUIPIER:uint=3;
		private var _DISPARITION:uint=4;
		
		private var _nomSimple:String;
		
		public function Objet():void {
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
			
			_absence = _jeu.verifierAbsence(this.name);//true = le nom est dans la liste des absences
			visible = !(_absence);//invisible si absent, visible si présent
		} //init

		/******************************************************************************
		Fonction cacher
		******************************************************************************/		
		public function cacher(desMaintenant:Boolean=true):void {
			_absence = true; // l'obstacle doit savoir qu'il sera absent
			_jeu.noterAbsence(this.name); // _jeu aussi, pour ne plus afficher cette instance lors du prochain affichage du tableau
			if(desMaintenant){visible = false;} // si ce n'est pas desMaintenant, l'instance demeure visible pour le moment
		} //cacher

		/******************************************************************************
		Fonction interagir
		  Elle permet de déclencher l'interaction liée à l'objet.
		  Attention, le nom d'instance doit être unique!
		  Si 2 objets ont le même nom d'instance, le ramassage d'un objet ferait disparaître les 2 objets.
		  (Cette version de la fonction a préséance sur la version de la classe Obstacle.)
		******************************************************************************/
		override public function interagir(modeTest:Boolean=false):String {
			var nomDuClip:String = this.name.toLowerCase();;
			var nomDialogue:String;
			var tSequence:Array;
			if(!_absence) { 
				//l'objet n'a pas été ramassé, il n'est pas absent, donc il y a une interaction
				log("rencontre avec cet objet : "+nomDuClip, 2);
				if(nomDuClip.indexOf("patate") >= 0) {
					_nomSimple = "Un objet!";
					tSequence = [
						[_REPLIQUE, "Vous avez trouvé une patate."], 
						[_OBJET, "Patate", 1],
						[_DISPARITION]
					];
					if( modeTest ){ return "Ok"; } //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
					_jeu.declencherDialogue(tSequence, this); // ajoutera l'objet à l'inventaire après l'affichage...;
					return "Dialogue";
				} else if(nomDuClip.indexOf("piece") >= 0) {
					_nomSimple = "Un trésor!";
					tSequence = [
						[_REPLIQUE, "Vous avez trouvé une pièce d'or."], 
						[_OBJET, "Or", 1],
						[_DISPARITION]
					];
					if( modeTest ){ return "Ok"; } //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
					_jeu.declencherDialogue(tSequence, this); //le nom du clip est ajouté pour permettre des «dialogues» successifs
					return "Dialogue";
				} else if(nomDuClip.indexOf("barriere") >= 0) {
					return ""; //l'objet bloque le passage
				} //if+else if
			} //if(!_absence)
			return "Absent"; //l'objet est forcément absent, il n'est plus là
		} //interagir
		
		/******************************************************************************
		*******************     FONCTIONS DE TESTS AUTOMATISÉS     ********************
		******************************************************************************/

		public function verifierSiValide():Boolean{ 
			var resultat:Boolean = false; //ici le test est un échec, jusqu'à preuve du contraire!
			
			//### Les règles à tester pour valider le nom de l'instance ###
			
			//#1. le nom doit contenir une des chaines permises:
			var tOptions:Array = ["piece", "patate", "barriere"]; //au besoin, d'autres options peuvent être ajoutée ici
			
			//donc on cherche un des types permis:
			for each(var unType:String in tOptions){
				if( name.indexOf(unType) ){ resultat = true; } //on a trouvé un match, c'est donc un test réussi jusqu'à présent
			}
			
			//#2. le nom doit se terminer par "_mc"
			if(name.slice(name.length-3) != "_mc"){
				resultat = false;
			} //c'est un échec si le nom ne se termine pas comme prévu...
			return resultat;
		} //verifierSiValide

		/******************************************************************************
		*******************************     GETTERS     *******************************
		******************************************************************************/
		public function getNomSimple():String{ return _nomSimple; }

	} //class
} //package