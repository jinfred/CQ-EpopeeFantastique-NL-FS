package {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

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
			var tempsActuel: uint = new Date().time;
			if (clipDemandeur != _clipDemandeur || (_memTempsFinDialogue + _delaiSansRepetition < tempsActuel)) {
				//Puisque ce n'est pas le même clipDemandeur ou que le délai est écoulé, on affiche!
				var nomDeObjet = clipDemandeur.toString();
				_iEtape = 0;
				_tSequence = tSequence;
				_clipDemandeur = clipDemandeur; //mémorisation, pour la prochaine fois
				if (nomDeObjet.indexOf("Marchand") >= 0 && clipDemandeur.getAssezDargent() == true) {
					btOui.visible = true;
					btNon.visible = true;
					btSuite.visible = false;
					btOui.addEventListener(MouseEvent.CLICK, acheterObjet(tSequence, clipDemandeur));
					btNon.addEventListener(MouseEvent.CLICK, refuserObjet);
				}
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
			//_jeu.enleverOr(_objet.getPrixObjet);	Ne fonctionnera pas, doit faire des modifications
			declencherEtape();
		}

		private function refuserObjet(e: Event = null): void {
			btNon.removeEventListener(MouseEvent.CLICK, refuserObjet);
			declencherEtape();
		}

		/******************************************************************************
		Fonction quitterDialogue
		******************************************************************************/
		private function quitterDialogue(e: Event = null): void {
			btSuite.removeEventListener(MouseEvent.CLICK, declencherEtape);

			message_txt.text = "";
			_memTempsFinDialogue = new Date().time; // notons le temps pour éviter de ravoir le même message immédiatement

			_jeu.terminerDialogue();
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

		/******************************************************************************
		Fonction frappeClavierDialogue
		  Elle est exécutée quand une touche du clavier est enfoncée pendant l'affichage du dialogue.
		******************************************************************************/
		public function frappeClavierDialogue(e: KeyboardEvent): void {
			switch (e.keyCode) {
				case Keyboard.SPACE:
				case Keyboard.ENTER:
					declencherEtape(e);
					break;
			} //switch
		} //frappeClavierDialogue

	} //class
} //package