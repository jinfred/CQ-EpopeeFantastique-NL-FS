package {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.display.*;

	public class Dialogue extends MovieClip {

		private var _tSequence: Array;
		private var _iEtape: uint;

		private var _memTempsFinDialogue: uint;
		private var _clipDemandeur: MovieClip;
		private var _delaiSansRepetition: uint = 4000;

		private var _REPLIQUE: uint = 0;
		private var _COMBAT: uint = 1;
		private var _OBJET: uint = 2;
		private var _EQUIPIER: uint = 3;
		private var _DISPARITION: uint = 4;

		private var _jeu: MovieClip;

		private var _nomDeObjet;

		private var dialogueMarchand: Boolean = false;

		private var _toggleOuiNon: int = -1; //-1 veut dire non, 1 veut dire oui

		private var tPersos: Array = [];
		private var _niveautPersos:int;

		public function Dialogue() {
			// CONSTRUCTEUR
			addEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, nettoyer);
		}

		/******************************************************************************
		Fonction init
		  Elle initialise les paramètres initiaux et déclenche la première étape
		******************************************************************************/
		private function init(e: Event): void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			_jeu = MovieClip(parent); // initialisation de la référence du parent

			this.x = 4;
			this.y = 520;
		} //init

		/******************************************************************************
		Fonction nettoyer
		******************************************************************************/
		private function nettoyer(e: Event): void {
			removeEventListener(Event.REMOVED_FROM_STAGE, nettoyer);
			// quelquechose d'autre à faire ici?
		} //nettoyer

		/******************************************************************************
		Fonction declencherSiOk
		******************************************************************************/
		public function declencherSiOk(tSequence: Array, clipDemandeur: MovieClip): Boolean {
			dialogueMarchand = false;
			var tempsActuel: uint = new Date().time;
			if (clipDemandeur != _clipDemandeur || (_memTempsFinDialogue + _delaiSansRepetition < tempsActuel)) {
				//Puisque ce n'est pas le même clipDemandeur ou que le délai est écoulé, on affiche!
				var nomDeObjet = clipDemandeur.toString();
				_nomDeObjet = nomDeObjet;
				_iEtape = 0;
				_tSequence = tSequence;
				trace(dialogueMarchand);
				_clipDemandeur = clipDemandeur; //mémorisation, pour la prochaine fois
				if (nomDeObjet.indexOf("Marchand") >= 0 && clipDemandeur.getAssezDargent() == true || nomDeObjet.indexOf("Puit") >= 0 && clipDemandeur.getAssezDargent() == true && _iEtape >= _tSequence.length && _tSequence.length >= 2) {
					dialogueMarchand = true;
				}
				if (dialogueMarchand) {
					btOui.visible = true;
					btNon.visible = true;
					btSuite.visible = false;
					btOui.addEventListener(MouseEvent.CLICK, acheterObjet(tSequence, clipDemandeur));
					btNon.addEventListener(MouseEvent.CLICK, refuserObjet);
				}
				dialogueMarchand = false;
				declencherEtape();
				btSuite.addEventListener(MouseEvent.CLICK, declencherEtape);
				return true; //true indique que le dialogue débute
			} else {
				return false; //false indique que le dialogue n'aura pas lieu
			} //if+else
		} //declencherSiOk


		private function acheterObjet(tSequence: Array, clipDemandeur: MovieClip): Function {
			return function (e: MouseEvent): void {
				btOui.removeEventListener(MouseEvent.CLICK, acheterObjet(tSequence, clipDemandeur));
				btNon.removeEventListener(MouseEvent.CLICK, refuserObjet);
				/*_tSequence = [
					[_REPLIQUE, "Vous avez acheté " + _clipDemandeur.getNomSimple()],
					[_OBJET, _clipDemandeur.getNomSimple(), 1],
					[_DISPARITION]
				];*/
				faireActionsAchat(tSequence, clipDemandeur);
				//declencherEtape();

			};
		}

		private function faireActionsAchat(tSequence: Array, clipDemandeur: MovieClip): void {
			_tSequence = [
				[_REPLIQUE, "Vous avez acheté " + clipDemandeur.getNomSimple()],
				[_OBJET, clipDemandeur.getNomSimple(), 1],
				[_DISPARITION]
			];
			var _prixItem = clipDemandeur.getPrixObjet()
			_jeu.enleverOr(_prixItem);
			_jeu.getEcranDeJeu().updateNbOr();
			var _nomDuClip = clipDemandeur.toString();

			//A REPARER ------------------------------------------------------
			
			/*if (_nomDuClip.indexOf("Puit") >= 0) {
				tPersos = _jeu.getTPersos();
				for (var i: uint = 0; i <= tPersos.length; i++) {
					_niveautPersos = tPersos[i].getNiveau();
					tPersos[i].setNiveau(_niveautPersos + 1);
					_jeu.soigner();
				}
			} else {
				for (var i: uint = 0; i <= tPersos.length; i++) {
					_niveautPersos = tPersos[i].getNiveau();
					tPersos[i].setNiveau(_niveautPersos + 1);
					trace("Niveau...^");
				}
			}*/
			
			//A REPARER -------------------------------------------------------
			
			dialogueMarchand = false;
			declencherEtape();
		}

		private function refuserObjet(e: Event = null): void {
			var tSequence = _tSequence;
			var clipDemandeur = _clipDemandeur;
			btNon.removeEventListener(MouseEvent.CLICK, refuserObjet);
			btOui.removeEventListener(MouseEvent.CLICK, acheterObjet(tSequence, clipDemandeur));
			btOui.removeEventListener(MouseEvent.CLICK, acheterObjet);
			dialogueMarchand = false;
			declencherEtape();
		}

		/******************************************************************************
		Fonction quitterDialogue
		******************************************************************************/
		private function quitterDialogue(e: Event = null): void {
			var tSequence = _tSequence;
			var clipDemandeur = _clipDemandeur;
			btOui.removeEventListener(MouseEvent.CLICK, acheterObjet(tSequence, clipDemandeur));
			btSuite.removeEventListener(MouseEvent.CLICK, declencherEtape);

			message_txt.text = "";
			_memTempsFinDialogue = new Date().time; // notons le temps pour éviter de ravoir le même message immédiatement
			dialogueMarchand = false;
			btOui.visible = false;
			btNon.visible = false;
			btSuite.visible = true;
			btNon.removeEventListener(MouseEvent.CLICK, refuserObjet);
			btOui.removeEventListener(MouseEvent.CLICK, acheterObjet);
			_jeu.terminerDialogue();

			if (_clipDemandeur.name.indexOf("LostWoodsDelwin") >= 0) {
				_jeu.getEcranDeJeu().sortTeleport_mc.visible = true;
			}

			if (_clipDemandeur.name.indexOf("pnjExcalibur_mc") >= 0) {
				_jeu.getEcranDeJeu().pnjExcalibur_mc.gotoAndStop("Sans Epee");
			}

		} //quitterDialogue

		/******************************************************************************
		Fonction declencherEtape
		  Elle passe à la prochaine étape et affiche au besoin.
		******************************************************************************/
		private function declencherEtape(e: Event = null): void {
			if (_iEtape >= _tSequence.length) {
				quitterDialogue();
			} else {
				var tEtape = _tSequence[_iEtape]; //récupération du sous-tableau (Array) tEtape

				// Contenu de tEtape:
				// tEtape[0] = type d'étape (_REPLIQUE/_COMBAT/_OBJET/_EQUIPIER/_DISPARITION)
				// tEtape[1] = chaine réplique (_REPLIQUE) / chaine type (_COMBAT / _OBJET) / booléen cacher sur le champ (_DISPARITION) 
				// tEtape[2] = nom spécial associé à une réplique (_REPLIQUE) / nombre d'objets (_OBJET)

				var typeEtape: uint = tEtape[0];

				_iEtape++; //incrémentation, pour la prochaine fois
				switch (typeEtape) {
					case _REPLIQUE:
						//c'est un texte à afficher
						var txtReplique: String = tEtape[1];
						var txtNomPerso: String = ((tEtape.length > 2) ? tEtape[2] : _clipDemandeur.getNomSimple()); //le nom prévu, sinon c'est le nom du demandeur
						message_txt.text = ((txtNomPerso != "") ? txtNomPerso + " – " : "") + txtReplique; //construction de la chaine à afficher
						if (_nomDeObjet.indexOf("Puit") >= 0) {
							if (_iEtape == _tSequence.length && _clipDemandeur.getAssezDargent() == true) {
								var clipDemandeur = _clipDemandeur;
								var tSequence = _tSequence;
								btOui.visible = true;
								btNon.visible = true;
								btSuite.visible = false;
								btOui.addEventListener(MouseEvent.CLICK, acheterObjet(tSequence, clipDemandeur));
								btNon.addEventListener(MouseEvent.CLICK, refuserObjet);

								//stage.addEventListener(KeyboardEvent.KEY_DOWN, funcToggleOuiNon);
								//stage.addEventListener(Event.ENTER_FRAME, toggleLoop);

							}

						}
						break;
					case _COMBAT:
						//c'est un combat a déclencher
						quitterDialogue();
						var typeCombat: String = tEtape[1];
						_jeu.amorcerCombat(typeCombat);
						break;
					case _OBJET:
						//c'est un objet a ajouter
						var typeObjet: String = tEtape[1];
						if (typeObjet == "Or") {
							var quantite: Number = ((tEtape.length > 2) ? tEtape[2] : 1); //la quantité prévue, sinon c'est 1 par défaut
							_jeu.ajouterOr(quantite); //ajouter l'or au trésor du joueur...
						} else {
							_jeu.ajouterObjet(typeObjet); //une mécanique plus élaborée serait souhaitable
						} //if+else
						break;
					case _EQUIPIER:
						//c'est un nouvel équipier a ajouter
						_jeu.ajouterPerso(_clipDemandeur.name); // le perso est maintenant dans l'équipe...
						break;
					case _DISPARITION:
						//il faut faire disparaître le clip (peut être un objet ou un PNJ)
						var desMaintenant: Boolean = ((tEtape.length > 2) ? tEtape[2] : true); //valeur demandée, ou «true» par défaut
						_clipDemandeur.cacher(desMaintenant); // le clip se cache et devient absent (si desMaintenant est faux, il sera absent au prochain affichage du tableau)
						break;
				} //switch
				if (typeEtape != _REPLIQUE) {
					declencherEtape(); //dans tous ces cas, on passe automatiquement à la prochaine étape de la séquence
				} //if

			} //if+else principal
		} //declencherEtape

		/*private function funcToggleOuiNon(e: KeyboardEvent): void {
			if (e.keyCode == 37) { //flèche de gauche
				_toggleOuiNon = -1;
				trace("Left");
				trace(_toggleOuiNon);
			}

			if (e.keyCode == 39) { //flèche de droite
				_toggleOuiNon = 1;
				trace("Right");
				trace(_toggleOuiNon);
			}


		}

		private function toggleLoop(e: Event): void {
			if (_toggleOuiNon == -1) {
				btOui.upState = btOui.overState;
				btNon.upState = btNon.upState;
			}

			if (_toggleOuiNon == 1) {
				btNon.upState = btNon.overState;
				btOui.upState = btOui.upState;
			}

		}*/

		private function updateBoutons(): void {
			if (_toggleOuiNon == 1) {
				btOui.downState = btOui.downState;
				btNon.upState = btNon.upState;
			}

			if (_toggleOuiNon == -1) {
				btNon.upState = btNon.downState;
				btOui.upState = btOui.upState;
			}

		}

		/******************************************************************************
		Fonction frappeClavierDialogue
		  Elle est exécutée quand une touche du clavier est enfoncée pendant l'affichage du dialogue.
		******************************************************************************/
		public function frappeClavierDialogue(e: KeyboardEvent): void {
			var currDownNon: DisplayObject = btNon.downState;
			var currDownOui: DisplayObject = btOui.downState;
			switch (e.keyCode) {
				case Keyboard.SPACE:
				case Keyboard.ENTER:
					declencherEtape(e);
					break;
			} //switch

			switch (e.keyCode) {
				case 39:
					_toggleOuiNon = 1;
					trace("Right");
					trace(_toggleOuiNon);
					break;
				case 37:
					_toggleOuiNon = -1;
					trace("Left");
					trace(_toggleOuiNon);
					break;
			}
			updateBoutons();
		} //frappeClavierDialogue

	} //class
} //package