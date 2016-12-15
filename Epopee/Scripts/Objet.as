package {
	import flash.display.MovieClip;
	import flash.events.Event;

	public class Objet extends Obstacle {
		private var _absence: Boolean;
		private var _tab: MovieClip;
		private var _jeu: MovieClip;

		private var _REPLIQUE: uint = 0;
		private var _COMBAT: uint = 1;
		private var _OBJET: uint = 2;
		private var _EQUIPIER: uint = 3;
		private var _DISPARITION: uint = 4;

		private var _nomSimple: String;
		private var _assezDargent: Boolean;
		private var _prixObjet: int = 0;

		public function Objet(): void {
			// CONSTRUCTEUR
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		/******************************************************************************
		Fonction init
		******************************************************************************/
		private function init(e: Event): void {
			// initialisation des références aux 2 parents:
			_tab = MovieClip(parent);
			_jeu = MovieClip(parent.parent);

			_absence = _jeu.verifierAbsence(this.name); //true = le nom est dans la liste des absences
			visible = !(_absence); //invisible si absent, visible si présent
		} //init

		/******************************************************************************
		Fonction cacher
		******************************************************************************/
		public function cacher(desMaintenant: Boolean = true): void {
			_absence = true; // l'obstacle doit savoir qu'il sera absent
			_jeu.noterAbsence(this.name); // _jeu aussi, pour ne plus afficher cette instance lors du prochain affichage du tableau
			if (desMaintenant) {
				visible = false;
			} // si ce n'est pas desMaintenant, l'instance demeure visible pour le moment
		} //cacher

		/******************************************************************************
		Fonction interagir
		  Elle permet de déclencher l'interaction liée à l'objet.
		  Attention, le nom d'instance doit être unique!
		  Si 2 objets ont le même nom d'instance, le ramassage d'un objet ferait disparaître les 2 objets.
		  (Cette version de la fonction a préséance sur la version de la classe Obstacle.)
		******************************************************************************/
		override public function interagir(modeTest: Boolean = false): String {
			var nomDuClip: String = this.name.toLowerCase();;
			var nomDialogue: String;
			var tSequence: Array;
			if (!_absence) {
				//l'objet n'a pas été ramassé, il n'est pas absent, donc il y a une interaction
				log("rencontre avec cet objet : " + nomDuClip, 2);
				if (nomDuClip.indexOf("patate") >= 0) {
					_nomSimple = "Un objet!";
					tSequence = [
						[_REPLIQUE, "Vous avez trouvé une patate."],
						[_OBJET, "Patate", 1],
						[_DISPARITION]
					];
					if (modeTest) {
						return "Ok";
					} //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
					_jeu.declencherDialogue(tSequence, this); // ajoutera l'objet à l'inventaire après l'affichage...;
					return "Dialogue";
				} else if (nomDuClip.indexOf("piece") >= 0) {
					_nomSimple = "Un trésor!";
					tSequence = [
						[_REPLIQUE, "Vous avez trouvé une pièce d'or."],
						[_OBJET, "Or", 1],
						[_DISPARITION]
					];
					if (modeTest) {
						return "Ok";
					} //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
					_jeu.declencherDialogue(tSequence, this); //le nom du clip est ajouté pour permettre des «dialogues» successifs
					return "Dialogue";
				} else if (nomDuClip.indexOf("barriere") >= 0) {
					return ""; //l'objet bloque le passage
				} //if+else if
				else if (nomDuClip.indexOf("instrumentdagan") >= 0) {
					_nomSimple = "L'instrument de Dagan !";
					tSequence = [
						[_REPLIQUE, "Vous avez trouvé l'instrument perdu de Dagan !"],
						[_REPLIQUE, "Vous avez promis de lui ramener à la taverne du village", ""],
						[_OBJET, "Instrument de Dagan", 1],
						[_DISPARITION]
					];
					_tab.obj_instrumentdagan_mc.gotoAndStop("Normal");
					_jeu.setPersoHasInstrumentDagan(true);
					if (modeTest) {
						return "Ok";
					} //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
					_jeu.declencherDialogue(tSequence, this); // ajoutera l'objet à l'inventaire après l'affichage...;
					return "Dialogue";
				} else if (nomDuClip.indexOf("marchand") >= 0) {
					trace(nomDuClip);
					if (nomDuClip == "epeemarchand_mc") {
						_assezDargent = false;
						_prixObjet = 1
						if (_jeu.getFortune() >= _prixObjet) {
							_assezDargent = true;
							_nomSimple = "L'épée d'Azkhaban";
							tSequence = [
								[_REPLIQUE, "Vous fait gagner un niveau. Voulez-vous l'acheter pour " + _prixObjet + " pièces d'or ?"],
								/*[_OBJET, "Epee", 1],
								[_DISPARITION]*/
							];
							if (modeTest) {
								return "Ok";
							} //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
							_jeu.declencherDialogue(tSequence, this); //le nom du clip est ajouté pour permettre des «dialogues» successifs
							return "Dialogue";
						} else {
							_nomSimple = "L'épée d'Azkhaban";
							tSequence = [
								[_REPLIQUE, "Vous avez besoin de " + _prixObjet + " pièces d'or pour acheter cet objet"],
							];
							if (modeTest) {
								return "Ok";
							} //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
							_jeu.declencherDialogue(tSequence, this); //le nom du clip est ajouté pour permettre des «dialogues» successifs
							return "Dialogue";
						} // else
					} //if "epeemarchand_mc"

					if (nomDuClip == "anneauemeraudemarchand_mc") {
						_assezDargent = false;
						_prixObjet = 1
						if (_jeu.getFortune() >= _prixObjet) {
							_assezDargent = true;
							_nomSimple = "L'anneau d'émeraude";
							tSequence = [
								[_REPLIQUE, "Vous fait gagner un niveau. Voulez-vous l'acheter pour " + _prixObjet + " pièces d'or ?"],
							];
							if (modeTest) {
								return "Ok";
							} //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
							_jeu.declencherDialogue(tSequence, this); //le nom du clip est ajouté pour permettre des «dialogues» successifs
							return "Dialogue";
						} else {
							_nomSimple = "L'anneau d'émeraude";
							tSequence = [
								[_REPLIQUE, "Vous avez besoin de " + _prixObjet + " pièces d'or pour acheter cet objet"],
							];
							if (modeTest) {
								return "Ok";
							} //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
							_jeu.declencherDialogue(tSequence, this); //le nom du clip est ajouté pour permettre des «dialogues» successifs
							return "Dialogue";
						} // else
					} //if "anneauEmeraudeMarchand_mc"

					if (nomDuClip == "sacpoudremarchand_mc") {
						_assezDargent = false;
						_prixObjet = 1
						if (_jeu.getFortune() >= _prixObjet) {
							_assezDargent = true;
							_nomSimple = "Un sac de poudre magique";
							tSequence = [
								[_REPLIQUE, "Vous fait gagner un niveau. Voulez-vous l'acheter pour " + _prixObjet + " pièces d'or ?"],
								/*[_OBJET, "Epee", 1],
								[_DISPARITION]*/
							];
							if (modeTest) {
								return "Ok";
							} //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
							_jeu.declencherDialogue(tSequence, this); //le nom du clip est ajouté pour permettre des «dialogues» successifs
							return "Dialogue";
						} else {
							_nomSimple = "Un sac de poudre magique";
							tSequence = [
								[_REPLIQUE, "Vous avez besoin de " + _prixObjet + " pièces d'or pour acheter cet objet"],
							];
							if (modeTest) {
								return "Ok";
							} //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
							_jeu.declencherDialogue(tSequence, this); //le nom du clip est ajouté pour permettre des «dialogues» successifs
							return "Dialogue";
						} // else
					} //if "sacPoudreMarchand_mc"

					if (nomDuClip == "anneausapphiremarchand_mc") {
						_assezDargent = false;
						_prixObjet = 10
						if (_jeu.getFortune() >= _prixObjet) {
							_assezDargent = true;
							_nomSimple = "L'anneau de sapphire";
							tSequence = [
								[_REPLIQUE, "Vous fait gagner un niveau. Voulez-vous l'acheter pour " + _prixObjet + " pièces d'or ?"],
								/*[_OBJET, "Epee", 1],
								[_DISPARITION]*/
							];
							if (modeTest) {
								return "Ok";
							} //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
							_jeu.declencherDialogue(tSequence, this); //le nom du clip est ajouté pour permettre des «dialogues» successifs
							return "Dialogue";
						} else {
							_nomSimple = "L'anneau de sapphire";
							tSequence = [
								[_REPLIQUE, "Vous avez besoin de " + _prixObjet + " pièces d'or pour acheter cet objet"],
							];
							if (modeTest) {
								return "Ok";
							} //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
							_jeu.declencherDialogue(tSequence, this); //le nom du clip est ajouté pour permettre des «dialogues» successifs
							return "Dialogue";
						} // else
					} //if "anneausapphiremarchand_mc"

					if (nomDuClip == "baguettemarchand_mc") {
						_assezDargent = false;
						_prixObjet = 10
						if (_jeu.getFortune() >= _prixObjet) {
							_assezDargent = true;
							_nomSimple = "Une baguette de pain bien chaude";
							tSequence = [
								[_REPLIQUE, "Vous fait gagner un niveau. Voulez-vous l'acheter pour " + _prixObjet + " pièces d'or ?"],
								/*[_OBJET, "Epee", 1],
								[_DISPARITION]*/
							];
							if (modeTest) {
								return "Ok";
							} //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
							_jeu.declencherDialogue(tSequence, this); //le nom du clip est ajouté pour permettre des «dialogues» successifs
							return "Dialogue";
						} else {
							_nomSimple = "Une baguette de pain bien chaude";
							tSequence = [
								[_REPLIQUE, "Vous avez besoin de " + _prixObjet + " pièces d'or pour acheter cet objet"],
							];
							if (modeTest) {
								return "Ok";
							} //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
							_jeu.declencherDialogue(tSequence, this); //le nom du clip est ajouté pour permettre des «dialogues» successifs
							return "Dialogue";
						} // else
					} //if "baguettemarchand_mc"


					if (nomDuClip == "pierreaiguisermarchand_mc") {
						_assezDargent = false;
						_prixObjet = 10
						if (_jeu.getFortune() >= _prixObjet) {
							_assezDargent = true;
							_nomSimple = "Une pierre à aiguiser";
							tSequence = [
								[_REPLIQUE, "Vous fait gagner un niveau. Voulez-vous l'acheter pour " + _prixObjet + " pièces d'or ?"],
								/*[_OBJET, "Epee", 1],
								[_DISPARITION]*/
							];
							if (modeTest) {
								return "Ok";
							} //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
							_jeu.declencherDialogue(tSequence, this); //le nom du clip est ajouté pour permettre des «dialogues» successifs
							return "Dialogue";
						} else {
							_nomSimple = "Une pierre à aiguiser";
							tSequence = [
								[_REPLIQUE, "Vous avez besoin de " + _prixObjet + " pièces d'or pour acheter cet objet"],
							];
							if (modeTest) {
								return "Ok";
							} //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
							_jeu.declencherDialogue(tSequence, this); //le nom du clip est ajouté pour permettre des «dialogues» successifs
							return "Dialogue";
						} // else
					} //if "pierreaiguisermarchand_mc"

					if (nomDuClip == "anneaurubismarchand_mc") {
						_assezDargent = false;
						_prixObjet = 20
						if (_jeu.getFortune() >= _prixObjet) {
							_assezDargent = true;
							_nomSimple = "L'anneau de rubis";
							tSequence = [
								[_REPLIQUE, "Vous fait gagner un niveau. Voulez-vous l'acheter pour " + _prixObjet + " pièces d'or ?"],
								/*[_OBJET, "Epee", 1],
								[_DISPARITION]*/
							];
							if (modeTest) {
								return "Ok";
							} //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
							_jeu.declencherDialogue(tSequence, this); //le nom du clip est ajouté pour permettre des «dialogues» successifs
							return "Dialogue";
						} else {
							_nomSimple = "L'anneau de rubis";
							tSequence = [
								[_REPLIQUE, "Vous avez besoin de " + _prixObjet + " pièces d'or pour acheter cet objet"],
							];
							if (modeTest) {
								return "Ok";
							} //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
							_jeu.declencherDialogue(tSequence, this); //le nom du clip est ajouté pour permettre des «dialogues» successifs
							return "Dialogue";
						} // else
					} //if "anneaurubismarchand_mc"


					if (nomDuClip == "bottesmarchand_mc") {
						_assezDargent = false;
						_prixObjet = 20
						if (_jeu.getFortune() >= _prixObjet) {
							_assezDargent = true;
							_nomSimple = "Les bottes d'Hermès";
							tSequence = [
								[_REPLIQUE, "Vous fait gagner un niveau. Voulez-vous l'acheter pour " + _prixObjet + " pièces d'or ?"],
								/*[_OBJET, "Epee", 1],
								[_DISPARITION]*/
							];
							if (modeTest) {
								return "Ok";
							} //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
							_jeu.declencherDialogue(tSequence, this); //le nom du clip est ajouté pour permettre des «dialogues» successifs
							return "Dialogue";
						} else {
							_nomSimple = "Les bottes d'Hermès";
							tSequence = [
								[_REPLIQUE, "Vous avez besoin de " + _prixObjet + " pièces d'or pour acheter cet objet"],
							];
							if (modeTest) {
								return "Ok";
							} //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
							_jeu.declencherDialogue(tSequence, this); //le nom du clip est ajouté pour permettre des «dialogues» successifs
							return "Dialogue";
						} // else
					} //if "bottesmarchand_mc"


					if (nomDuClip == "eaumarchand_mc") {
						_assezDargent = false;
						_prixObjet = 20
						if (_jeu.getFortune() >= _prixObjet) {
							_assezDargent = true;
							_nomSimple = "Une bouteille d'eau bénite";
							tSequence = [
								[_REPLIQUE, "Vous fait gagner un niveau. Voulez-vous l'acheter pour " + _prixObjet + " pièces d'or ?"],
								/*[_OBJET, "Epee", 1],
								[_DISPARITION]*/
							];
							if (modeTest) {
								return "Ok";
							} //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
							_jeu.declencherDialogue(tSequence, this); //le nom du clip est ajouté pour permettre des «dialogues» successifs
							return "Dialogue";
						} else {
							_nomSimple = "Une bouteille d'eau bénite";
							tSequence = [
								[_REPLIQUE, "Vous avez besoin de " + _prixObjet + " pièces d'or pour acheter cet objet"],
							];
							if (modeTest) {
								return "Ok";
							} //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
							_jeu.declencherDialogue(tSequence, this); //le nom du clip est ajouté pour permettre des «dialogues» successifs
							return "Dialogue";
						} // else
					} //if "eaumarchand_mc"


				} // else if "marchand"
				else if (nomDuClip.indexOf("puit") >= 0) {
					_assezDargent = false;
					_prixObjet = 1
					if (_jeu.getFortune() >= _prixObjet) {
						_assezDargent = true;
						_nomSimple = "Spéro";
						tSequence = [
							[_REPLIQUE, "Un puits magique !"],
							[_REPLIQUE, "Certain disent qu'il te donne des pouvoirs magiques si tu lance une pièce d'or..."],
							[_REPLIQUE, "Devrais-je lancer une pièce d'or ?"],
						];
						if (modeTest) {
							return "Ok";
						} //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
						_jeu.declencherDialogue(tSequence, this); //le nom du clip est ajouté pour permettre des «dialogues» successifs
						return "Dialogue";
					} else {
						_nomSimple = "Spéro";
						tSequence = [
							[_REPLIQUE, "Un puits magique !"],
							[_REPLIQUE, "Certain disent qu'il te donne des pouvoirs magiques si tu lance une pièce d'or..."],
							[_REPLIQUE, "Si seulement j'avais une pièce d'or à lancer..."],
						];
						if (modeTest) {
							return "Ok";
						} //si appelé par la fn verifierSiValide(), on quitte avant de faire plus (sans erreur)
						_jeu.declencherDialogue(tSequence, this); //le nom du clip est ajouté pour permettre des «dialogues» successifs
						return "Dialogue";
					} // else

				}
			} //if(!_absence)
			return "Absent"; //l'objet est forcément absent, il n'est plus là
		} //interagir

		/******************************************************************************
		 *******************     FONCTIONS DE TESTS AUTOMATISÉS     ********************
		 ******************************************************************************/

		public function verifierSiValide(): Boolean {
			var resultat: Boolean = false; //ici le test est un échec, jusqu'à preuve du contraire!

			//### Les règles à tester pour valider le nom de l'instance ###

			//#1. le nom doit contenir une des chaines permises:
			var tOptions: Array = ["piece", "patate", "barriere"]; //au besoin, d'autres options peuvent être ajoutée ici

			//donc on cherche un des types permis:
			for each(var unType: String in tOptions) {
				if (name.indexOf(unType)) {
					resultat = true;
				} //on a trouvé un match, c'est donc un test réussi jusqu'à présent
			}

			//#2. le nom doit se terminer par "_mc"
			if (name.slice(name.length - 3) != "_mc") {
				resultat = false;
			} //c'est un échec si le nom ne se termine pas comme prévu...
			return resultat;
		} //verifierSiValide

		/******************************************************************************
		 *******************************     GETTERS     *******************************
		 ******************************************************************************/
		override public function getNomSimple(): String {
			return _nomSimple;
		}

		public function getAssezDargent(): Boolean {
			return _assezDargent;
		}

		public function getPrixObjet(): Boolean {
			return _prixObjet;
		}

	} //class
} //package