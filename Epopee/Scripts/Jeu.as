package {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getDefinitionByName;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.geom.Point;
	import flash.system.Capabilities;

	public class Jeu extends MovieClip {
		private var _txtVersion: String = "Version 1.2.1 Finale (2016-10-07)"; //exemple: "Version 2.0 Alpha 1 (2016-10-16)"

		private var _zonesTechniquesVisibles: Boolean = false;

		private var _debogage_mc: Debogage = new Debogage(this);

		private var _ecranDeJeu: MovieClip; // MovieClip, tableau/combat/menu affiché
		private var _memNomEcran: String; // Chaine, nom de l'écran précédent (pour retour après menu ou combat)
		private var _memPosPerso: Point; // Point, position du perso dans l'écran précédent (X, Y)

		private var _dialogue = new Dialogue();
		private var _dialogueMarchand = new DialogueMarchand();
		private var _estEnDialogue: Boolean = false;

		private var _facteurTemps: Number = 1;

		private var _prochainCombat: int // Entier, nombre de tours avant le prochain combat
		private var _combatPossible: Boolean = false; // Booleen, indique si l'écran en cours permet les combats
		private var _tTableauxPacifiques: Array = ["Village", "Foret", "MaisonAmi", "MaisonMaman", "SalleDuRoi", "Marchand1", "Marchand2", "Village2", "Foret2", "Marais05", "Lac", "RavinChateau", "InterieurTemple", "Temple", "EntreeVille", "Ville", "Marais04", "Entree", "Taverne", "SalleDuRoi"];
		private var _tTableauxDangereux: Array = ["foretEnchantee02", "foretEnchantee03", "foretEnchantee04", "foretEnchantee05", "Marais01", "Marais02", "Marais03", "Chateau"];
		private var _tTousLesTableaux: Array = _tTableauxPacifiques.concat(_tTableauxDangereux); //permet de créer un Array contenant tous les tableaux

		private var _distance: Number;
		private var _gauche: Boolean = false,
			_droite: Boolean = false,
			_haut: Boolean = false,
			_bas: Boolean = false;

		private var _spero: Perso, _Caitlyn: Perso, _Dagan: Perso, _Delwin: Perso;
		private var _tPersos: Array;
		private var _tAbsences: Array = [];
		private var _tObjets: Array = [];
		private var _fortune: Number = 0;

		private var _transitionCombat: MovieClip = new TransitionCombat();
		private var _transitionVictoire: MovieClip = new TransitionVictoire();

		private var _musique: Sound;
		private var _pisteAudio: SoundChannel;
		private var _musiqueOn: Boolean = true;

		private var _ctrlPadActif: Boolean = (Capabilities.cpuArchitecture == "ARM"); //mécanique à développer
		private var _ctrlPad: CtrlPad;
		private var _btMenuInfo: BtMenuInfo;

		private var _persoHasExcalibur = false;
		private var _persoHasInstrumentDagan = false;
		private var _persoHasDagan:Boolean = false;
		private var _persoHasCaitlyn:Boolean = false;
		private var _persoHasDelwin:Boolean = false;
		private var _persoHasDelwinTeleport:Boolean = false;
		private var _cheminForetEstLibre = false;


		public function Jeu() {
			// CONSTRUCTEUR
			// création des personnages amis, puis définition de leurs caractéristiques:
			_spero = new PersoSpero();
			_Caitlyn = new PersoCaitlyn();
			_Dagan = new PersoDagan();
			_Delwin = new PersoDelwin();
			//caractéristiques:    nom, PVAct, PVMax, PMAct, PMMax, baseAtt, baseDef, baseAttMag, baseDefMag, baseVites	se, niv, XPAct, XPSuivant, estPresent
			_spero.initParam("Spero", 125, 125, 50, 50, 25, 25, 5, 5, 20, 1, 0, 100, true);
			_Caitlyn.initParam("Caitlyn", 100, 100, 10, 10, 20, 20, 15, 10, 10, 1, 0, 100, false);
			_Dagan.initParam("Dagan", 50, 50, 75, 75, 10, 15, 25, 25, 25, 1, 0, 100, false);
			_Delwin.initParam("Delwin", 75, 75, 175, 175, 5, 10, 30, 30, 15, 1, 0, 300, false);

			_tPersos = [_spero]; //ajout du perso principal dans le Array de l'équipe

			addEventListener(Event.ADDED_TO_STAGE, init);
		} //function

		/******************************************************************************
		Fonction init
		  Elle initialise les paramètres initiaux, prépare le premier tableau.
		******************************************************************************/
		private function init(e: Event): void {
			montrerCtrlPad();
			prevoirProchainCombat();
			changerEcranJeu("Village", "teleport_MaisonMaman_mc"); //nomEcran, nomInstanceDuTeleport
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.ENTER_FRAME, loop);
		} //init

		/******************************************************************************
		Fonction changerEcranJeu
		  Elle exécute l'affichage des tableaux, des combats et du menu.
		  Elle reçoit le nom de «l'ecran» (nom du tableau, combat ou menu)
		  Pour les tableaux, elle reçoit la nouvelle position en x et y du héros.
		******************************************************************************/
		public function changerEcranJeu(nomEcran: String, nomTeleport: String = null): void {
			log("¤¤¤¤¤¤ nomEcran=" + nomEcran + " nomTeleport=" + nomTeleport, 2)

			if (nomEcran == null) {
				nomEcran = _memNomEcran;
				log("...de retour vers «" + nomEcran + "»", 2);
			} // si nomEcran est null, il faut retourner au tableau mémorisé
			if (_ecranDeJeu != null) {
				fermetureTableauEnCours();
			} else {
				log("c'est le premier tableau...", 3);
			}

			if (nomEcran.indexOf("Combat") >= 0) { //si le nom de l'écran contient le mot combat:
				_ecranDeJeu = new Combat(_tPersos, nomEcran);
				_combatPossible = false;
				_gauche = false, _droite = false, _haut = false, _bas = false; //arret des mouvements en cours
				addChild(_ecranDeJeu);
				//rappel: comme c'est un combat... l'essentiel de la gestion n'a pas lieu ici!
			} else if (nomEcran == "MenuInfo") { //si c'est le menu
				_ecranDeJeu = new MenuInfo(_tPersos);
				_combatPossible = false;
				_gauche = false, _droite = false, _haut = false, _bas = false; //arret des mouvements en cours
				addChild(_ecranDeJeu);
			} else { //tous les autres cas (donc les tableaux):
				try {
					var laClasse: Class = getDefinitionByName("Tab" + nomEcran) as Class;
					_ecranDeJeu = new laClasse();
				} catch (e: Error) {
					log("BOGUE MAJEUR: Le tableau «Tab" + nomEcran + "» est inconnu... Allons voir maman pour pleurer! (" + e + ")", 2);
					nomEcran = "MaisonMaman";
					_ecranDeJeu = new TabMaisonMaman();
				} //try+catch
				if (_tTableauxPacifiques.indexOf(nomEcran) >= 0) {
					_combatPossible = false;
				} //pas de combat dans les tableaux paisibles...
				else {
					_combatPossible = true;
				} //sinon, il y a des combats possibles dans tous les autres tableaux
				addChild(_ecranDeJeu); //note: le addChild doit avoir lieu avant initParam!
				_ecranDeJeu.initParam(_tPersos, nomTeleport); // pcq Flash ne permet pas de passer des paramètres au constructeur d'une classe générée automatiquement (utilisant une classe de base)
				if (_ctrlPadActif) {
					addChild(_ctrlPad);
				}
				creerBtnMenuInfo();
				_memNomEcran = nomEcran;
				log("+++_memNomEcran " + _memNomEcran, 3); // au besoin, cette variable sera utilisée au retour des combats
				addEventListener(Event.ENTER_FRAME, loop);
			} //if+else if+else
			jouerMusique(nomEcran);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, frappeClavier);
			stage.addEventListener(KeyboardEvent.KEY_UP, arretFrappeClavier);
			stage.focus = stage;
		} //changerEcranJeu

		/******************************************************************************
		Fonction verifierSiCombat
		  Elle réduit le délai avant une bataille et teste si c'est le moment d'en déclencher une.
		******************************************************************************/
		public function verifierSiCombat(): void {
			if (_combatPossible) {
				_prochainCombat -= 1;
				if (_prochainCombat % 20 == 0) {
					log("nb de deplacements avant bataille = " + _prochainCombat, 2);
				} //affichage de l'info à chaque 20 déplacements
				else if (_prochainCombat % 5 == 0) {
					log("nb de deplacements avant bataille = " + _prochainCombat, 3);
				} //affichage à chaque 5 déplacements
			} //if
			if (_prochainCombat <= 0) {
				amorcerCombat();
			}
		} //verifierSiCombat

		/******************************************************************************
		Fonction amorcerCombat
		  Elle exécute le démarrage du système du combat
		******************************************************************************/
		public function amorcerCombat(typeCombat: String = ""): void {
			log("UN COMBAT DOIT S'AMORCER!", 2);
			changerEcranJeu("Combat" + typeCombat);
			addChild(_transitionCombat);
			_transitionCombat.play();
		} //amorcerCombat

		/******************************************************************************
		Fonction finirCombat
		  Elle commande le changement d'écran après un combat.  
		  Elle est exécutée lorsque le joueur gagne ou fuit le combat.
		******************************************************************************/
		public function finirCombat(e: Event = null): void {
			prevoirProchainCombat();
			changerEcranJeu(null); // le perso sera remis à sa place, dans son ancien tableau
			addChild(_transitionVictoire);
			_transitionVictoire.play();
		} //finirCombat

		/******************************************************************************
		Fonction ouvrirMenuInfo
		******************************************************************************/
		public function ouvrirMenuInfo(e: Event = null): void {
			log("ouvrirMenuInfo...", 3);
			changerEcranJeu("MenuInfo");
		} //ouvrirMenuInfo

		/******************************************************************************
		Fonction fermerMenuInfo
		******************************************************************************/
		public function fermerMenuInfo(e: Event = null): void {
			log("fermerMenuInfo...", 3);
			changerEcranJeu(null); // le perso sera remis à sa place, dans son ancien tableau
		} //fermerMenuInfo

		/******************************************************************************
		Fonction declencherDialogue
		  Elle permet d'afficher un dialogue, et elle bloque les autres interactions.
		  Elle attend un Array 2D contenant les étapes du dialogue.
		  Chaque étape est elle-même un Array. Le premier élément de celui-ci indique
		  si c'est une réplique, un combat ou un dialogue.
		******************************************************************************/
		public function declencherDialogue(tSequence: Array, demandeur: MovieClip): Boolean {
			if (_dialogue.declencherSiOk(tSequence, demandeur)) {
				addChild(_dialogue);
				_estEnDialogue = true; //est utilisé pour prévenir les déplacements du perso
				_gauche = false, _droite = false, _haut = false, _bas = false; //arret de tous les mouvements en cours 
				_ecranDeJeu.arreterJoueur(_spero);
				return true; //signifie que le dialogue a eu lieu
			} else {
				return false; //signifie que le dialogue n'a pas eu lieu
			} //if+else
		} //declencherDialogue

		/******************************************************************************
		Fonction terminerDialogue
		  Elle masque le dialogue, et libère les actions.
		******************************************************************************/
		public function terminerDialogue(): void {
			if (this.contains(_dialogue)) {
				removeChild(_dialogue);
			} //si le dialogue est là, on l'enlève (n'est pas là après combat)
			_estEnDialogue = false; //permet les déplacements du perso...
			stage.focus = stage;
		} //terminerDialogue

		/******************************************************************************
		Fonction prevoirProchainCombat
		  Elle détermine le moment du prochain combat.
		******************************************************************************/
		public function prevoirProchainCombat(): void {
			// détermine le nombre de déplacements permis avant le prochain combat
			_prochainCombat = Math.ceil(Math.random() * 400);
			log("nombre de tours avant le prochain combat : " + _prochainCombat, 2);
		} //prevoirProchainCombat

		/******************************************************************************
		Fonction frappeClavier
		  Elle est exécutée quand une touche du clavier est enfoncée.
		******************************************************************************/
		public function frappeClavier(e: KeyboardEvent): void {
			var touche: uint = e.keyCode;
			var lettre: String = String.fromCharCode(e.charCode);

			switch (touche) {
				//les touches suivantes ne déclenchent pas directement les actions, donc...
				case Keyboard.COMMAND:
				case Keyboard.CONTROL:
				case Keyboard.SHIFT:
					return; //...arret de la fn
			} //switch

			log("touche = " + touche + " (lettre = " + lettre + ")", 3);

			if (_debogage_mc.frappeClavierDebogage(e)) {
				//le relai a été transmis au débogage, si la fn a répondu true
				//la touche a été «captée» par le débogage rien d'autre ne doit être fait
			} else if (_estEnDialogue) {
				// dans ce cas, on relaie la frappe clavier à la fonction du dialogue:
				_dialogue.frappeClavierDialogue(e);
			} else if (_ecranDeJeu is Combat) {
				// dans ce cas, on relaie la frappe clavier à la fonction de l'écran du combat:
				_ecranDeJeu.frappeClavierCombat(e);
			} else if (_ecranDeJeu is MenuInfo) {
				// dans ce cas, on relaie la frappe clavier à la fonction de l'écran des infos:
				_ecranDeJeu.frappeClavierMenuInfo(e);
			} else if (_ecranDeJeu is Tableau) {
				switch (touche) {
					case Keyboard.LEFT:
						_gauche = true;
						break;
					case Keyboard.RIGHT:
						_droite = true;
						break;
					case Keyboard.UP:
						_haut = true;
						break;
					case Keyboard.DOWN:
						_bas = true;
						break;
					case Keyboard.I:
						ouvrirMenuInfo();
						break; // la touche «i» ouvre le menu des infos 
				} //switch

			} //if+else if
		} //frappeClavier

		/******************************************************************************
		Fonction arretFrappeClavier
		  Elle est exécutée quand une touche du clavier est relevée.
		******************************************************************************/
		public function arretFrappeClavier(e: KeyboardEvent): void {
			var touche: uint = e.keyCode;
			if (_ecranDeJeu is Tableau) {
				switch (touche) {
					case Keyboard.LEFT:
						_gauche = false;
						break;
					case Keyboard.RIGHT:
						_droite = false;
						break;
					case Keyboard.UP:
						_haut = false;
						break;
					case Keyboard.DOWN:
						_bas = false;
						break;
				} //switch
				if (!_gauche && !_droite && !_haut && !_bas) {
					_ecranDeJeu.arreterJoueur(_spero);
				} //au besoin, arret du cycle de marche
			} //if
		} //arretFrappeClavier

		/******************************************************************************
		Fonction montrerCtrlPad
		  Elle permet de montrer le ctrlPad si _ctrlPadActif == true.
		******************************************************************************/
		public function montrerCtrlPad(forcer: Boolean = false): void {
			if (forcer) {
				_ctrlPadActif = !_ctrlPadActif;
			} //inversion de l'état
			if (_ctrlPadActif) {
				_ctrlPad = new CtrlPad();
				_ctrlPad.x = 80;
				_ctrlPad.y = 650;
				if (_ctrlPad.parent == null) {
					addChild(_ctrlPad);
				} //on l'ajoute, sauf s'il est déjà là...
			} else {
				if (forcer) {
					if (_ctrlPad != null) {
						removeChild(_ctrlPad);
					}
				} //si il y a un _ctrlPad, on l'enlève...
			} //if+else
		} //montrerCtrlPad

		/******************************************************************************
		Fonction bougerPad
		  Elle est exécutée quand un bouton du pad est enfoncé ou relâché.
		******************************************************************************/
		public function bougerPad(gauche: Boolean, droite: Boolean, haut: Boolean, bas: Boolean): void {
			_gauche = gauche;
			_droite = droite;
			_haut = haut;
			_bas = bas;
			if (!_gauche && !_droite && !_haut && !_bas) {
				_ecranDeJeu.arreterJoueur(_spero);
			} //au besoin, arret du cycle de marche
		} //boucherPad

		/******************************************************************************
		Fonction creerBtnMenuInfo
		  Création du bouton qui permet d'afficher le menu info.
		******************************************************************************/
		public function creerBtnMenuInfo(): void {
			_btMenuInfo = new BtMenuInfo();
			_btMenuInfo.x = 1220;
			_btMenuInfo.y = 660;
			_btMenuInfo.addEventListener(MouseEvent.CLICK, ouvrirMenuInfo);
			addChild(_btMenuInfo);
		} //creerBtnMenuInfo

		/******************************************************************************
		Fonction loop
		  Elle est exécutée à chaque enterFrame. Elle contrôle l'animation du déplacement.
		******************************************************************************/
		private function loop(e: Event): void {
			var _distance: uint = 6;
			if (_ecranDeJeu is Tableau) {
				var vX: Number = 0,
					vY: Number = 0; //les vecteurs de mouvements sont initialisés
				if (_gauche) {
					vX -= _distance;
				}
				if (_droite) {
					vX += _distance;
				}
				if (_haut) {
					vY -= _distance;
				}
				if (_bas) {
					vY += _distance;
				}
				if (vX != 0 && vY != 0) { //si le personnage marche en diagonale, on réduit les vecteurs (plus réaliste)
					//var angleRad = 45 * Math.PI / 180;
					vX *= 0.71 //Math.cos(angleRad)=0.7071067811865475;
					vY *= 0.71 //Math.sin(angleRad)=0.7071067811865475;
				} //if
				if (vX != 0 || vY != 0) {
					_ecranDeJeu.deplacerJoueur(_spero, vX, vY);
				} //le déplacement est demandé seulement si il y a un vecteur pertinant!
			} //if(c'est un Tableau)
		} //loop

		/******************************************************************************
		Fonction soigner
		  Elle est exécutée quand le joueur visite sa mère. 
		  Elle permet de soigner tous les membres de l'équipe.
		  Chaque perso récupérera tous ses points, même s'il est mort.
		******************************************************************************/
		public function soigner(valeurDeSoin: int = int.MAX_VALUE): void {
			for each(var perso: Perso in _tPersos) {
				perso.guerir(valeurDeSoin, true);
			}
		} //soigner

		/******************************************************************************
		Fonction verifierAbsence
		  Elle est exécutée quand le lieu d'attache d'un PNJ est visité.
		  Elle permet de vérifier si le PNJ doit être affiché ou pas.
		  Elle reçoit le nom de l'instance du PNJ en paramètre.
		******************************************************************************/
		public function verifierAbsence(nomInstance): Boolean {
			return (_tAbsences.indexOf(nomInstance) >= 0);
		} //verifierAbsence

		/******************************************************************************
		Fonction verifierTableau
		  Elle permet de vérifier si un tableau existe (retourne true/false)
		******************************************************************************/
		public function verifierTableau(nomTableau: String = null): Boolean {
			if ((_tTousLesTableaux.indexOf(nomTableau) == -1)) {
				//mécanisme de contrôle (si c'est vraiment un tableau, ajoutez-le à _tTableauxPacifiques ou _tTableauxDangereux)
				log("*&?%$/! L'écran demandé est invalide. !/$%?&*", 2);
				return false; //le tableau n'est pas dans le Array...
			} else {
				return true;
			} //if+else
		} //verifierTableau

		/******************************************************************************
		Fonction noterAbsence
		  Elle est exécutée quand un PNJ doit quitter son lieu d'appartenance.
		******************************************************************************/
		public function noterAbsence(nomInstance): void {
			if (_tAbsences.indexOf(nomInstance) < 0) {
				_tAbsences.push(nomInstance);
				log(nomInstance + " est maintenant dans les absences : " + _tAbsences, 2);
			} else {
				log("BOGUE: " + nomInstance + " était déjà dans la liste des absences... Erreur probable de nom d'instance. À vérifier.", 2)
			} //if+else
		} //noterAbsence

		/******************************************************************************
		Fonction ajouterPerso
		  Elle est exécutée quand un équipier se joint au groupe, 
		  pour l'ajouter au Array des membres de l'équipe.
		  Elle reçoit en paramètre le nom de l'instance du PNJ représentant l'équipier.
		******************************************************************************/
		public function ajouterPerso(nomInstance): void {
			var lePerso: Perso; //référence temporaire à un perso précis
			switch (nomInstance) {
				case "pnjCaitlyn_mc":
					lePerso = _Caitlyn;
					break;
				case "pnjDagan_mc":
					lePerso = _Dagan;
					break;
				case "pnjDelwin_mc":
					lePerso = _Delwin;
					break;
			} //switch
			if (_tPersos.length <= 3) {
				lePerso.setEstPresent(true);
				_tPersos.push(lePerso);
				log("Équipe += " + nomInstance, 2);
			} else {
				log("BOGUE: Impossible d'ajouter " + nomInstance + " parce que le nombre maximal d'équipiers a été atteint", 2); //protection, surtout au cas où les personnages sont ajoutés par les raccourcis
			} //if+else
		} //ajouterPerso

		/******************************************************************************
		Fonction ajouterPersoDebogage
		  Elle est exécutée pour ajouter/retirer un perso en debogage.
		  Elle reçoit en paramètre le nom de l'instance du PNJ représentant l'équipier.
		******************************************************************************/
		public function ajouterPersoDebogage(nomInstance): void {
			if (verifierAbsence(nomInstance)) {
				//le personnage était déjà dans l'équipe, nous allons l'enlever:
				_tAbsences.splice(_tAbsences.indexOf(nomInstance), 1)
				var lePerso: Perso; //référence temporaire à un perso précis
				switch (nomInstance) {
					case "pnjCaitlyn_mc":
						lePerso = _Caitlyn;
						break;
					case "pnjDagan_mc":
						lePerso = _Dagan;
						break;
					case "pnjDelwin_mc":
						lePerso = _Delwin;
						break;
				} //switch
				lePerso.setEstPresent(false);
				_tPersos.splice(_tPersos.indexOf(lePerso), 1);
			} else {
				//le personnage n'étant pas déjà dans la liste d'absence, il peut être ajouté à l'équipe:
				ajouterPerso(nomInstance);
				noterAbsence(nomInstance);
			} //if+else
		} //ajouterPersoDebogage

		/******************************************************************************
		Fonction ajouterObjet
		  Elle est exécutée quand le joueur trouve un objet.
		  Elle reçoit en paramètre le nom de l'objet à mettre dans l'inventaire.
		******************************************************************************/
		public function ajouterObjet(monObjet): void {
			_tObjets.push(monObjet);
		} //ajouterObjet

		/******************************************************************************
		Fonction arreterMusique
		  Elle arrête la musique qui jouait.
		******************************************************************************/
		public function arreterMusique(): void {
			_pisteAudio.stop();
		} //arreterMusique

		/******************************************************************************
		Fonction jouerMusique
		  Elle reçoit en paramètre le nom d'une musique et la fait jouer.
		******************************************************************************/
		public function jouerMusique(nomMusique: String, redemarrage: Boolean = false): void {
			var nomMusiqueEnCours: String = getQualifiedClassName(_musique);

			switch (nomMusique) {
				case "CombatChef":
					nomMusique = "MusiqueCombatFinal";
					break;
				case "CombatSousChef1":
				case "Combat":
					nomMusique = "MusiqueCombat";
					break;
				case "Ravin":
				case "Rocaille":
					nomMusique = "MusiqueCornemuse";
					break;
				case "Caverne":
					nomMusique = "MusiqueClavier";
					break;
				case "Foret":
					nomMusique = "MusiqueForet";
					break;
				case "Foret2":
					nomMusique = "MusiqueTambour";
					break;
				case "MaisonChamane":
					nomMusique = "MusiqueHarpe";
					break;
				case "Ville":
					nomMusique = "MusiqueVillage2";
					break;
				case "SalleDuRoi":
					nomMusique = "MusiqueClavier";
					break;
				case "Entree":
					nomMusique = "MusiqueClavier";
					break;
				case "foretEnchantee02":
					nomMusique = "MusiqueTambour";
					break;
				case "foretEnchantee03":
					nomMusique = "MusiqueTambour";
					break;
				case "foretEnchantee04":
					nomMusique = "MusiqueTambour";
					break;
				case "foretEnchantee05":
					nomMusique = "MusiqueTambour";
					break;
				default:
					if (redemarrage) {
						nomMusique = nomMusiqueEnCours; //dans ce cas, on veut relancer la musique précédente (POUR DÉBOGAGE)
					} else {
						nomMusique = "MusiqueVillage";
					} //if+else
					break;
			} //switch
			log("## Musique en onde : " + nomMusiqueEnCours + " / Nouveau choix musical : " + nomMusique, 2);
			if (nomMusique == nomMusiqueEnCours && !redemarrage) {
				// rien à faire, la musique doit continuer
			} else {
				try {
					var laClasse: Class = getDefinitionByName(nomMusique) as Class;
					_musique = new laClasse();
				} catch (e: Error) {
					log("BOGUE: La musique demandée n'existe pas... nomMusique: " + nomMusique + " (" + e + ")", 2);
				} //try+catch

				if (nomMusiqueEnCours != "null") {
					arreterMusique();
					log("Arrêtez la  musique svp!", 2);
				}

				if (_musiqueOn) {
					_pisteAudio = _musique.play(0, int.MAX_VALUE);
				} //la lecture se fera en boucle, presque à l'infini...
			} //if+else
		} //jouerMusique

		/******************************************************************************
		Fonction ajouterOr
		  Elle reçoit en paramètre le nombre de pièces d'or à ajouter à la fortune du joueur.
		******************************************************************************/
		public function ajouterOr(nbOr: Number): void {
			_fortune += nbOr;
		} //ajouterOr

		/******************************************************************************
		Fonction enleverOr
		  Elle reçoit en paramètre le nombre de pièces d'or à retirer de la fortune du joueur.
		******************************************************************************/
		public function enleverOr(nbOr: Number): void {
			_fortune -= nbOr;
			if (_fortune <= 0) {
				_fortune = 0;
			}
		} //enleverOr

		/******************************************************************************
		Fonction montrerAnimFinale
		  Elle mène à l'écran du générique en cas de victoire ou au cimetière...
		******************************************************************************/
		public function montrerAnimFinale(estVictorieux: Boolean): void {
			fermetureTableauEnCours();
			SoundMixer.stopAll(); // l'arrêt du son prévient un bogue de Flash avec le framerate
			if (this.contains(_debogage_mc)) {
				removeChild(_debogage_mc);
			} //changement du 8 octobre 2016: on l'enlève seulement si c'est l'enfant de jeu
			var destinationFinale: String = ((estVictorieux) ? "fin" : "cimetiere");
			MovieClip(parent).gotoAndStop(destinationFinale);
		} //montrerAnimFinale

		/******************************************************************************
		Fonction fermetureTableauEnCours
		  Elle ferme le tableau.
		******************************************************************************/
		private function fermetureTableauEnCours(): void {
			if (_ecranDeJeu is Tableau) {
				_memPosPerso = _spero.getPosPerso();
				if (_ctrlPadActif) {
					removeChild(_ctrlPad);
				}
				removeChild(_btMenuInfo);
			} //if

			stage.removeEventListener(KeyboardEvent.KEY_DOWN, frappeClavier); //par sécurité, on enleve l'interaction clavier jusqu'à l'arrivée du nouveau tableau
			stage.removeEventListener(KeyboardEvent.KEY_UP, arretFrappeClavier); //idem
			removeEventListener(Event.ENTER_FRAME, loop); //encore par sécurité
			removeChild(_ecranDeJeu);
		} //fermetureTableauEnCours

		/******************************************************************************
		 *******************************     GETTERS     *******************************
		 ******************************************************************************/
		public function getMemPosPerso(): Point {
			return _memPosPerso;
		}
		public function getEstEnDialogue(): Boolean {
			return _estEnDialogue;
		}
		public function getTxtVersion(): String {
			return _txtVersion;
		} //pour débogage, ne pas supprimer cette ligne!
		public function getFortune(): Number {
			return _fortune;
		} //pour débogage, ne pas supprimer cette ligne!
		public function getDistance(): Number {
			return _distance;
		} //pour débogage, ne pas supprimer cette ligne!
		public function getTObjets(): Array {
			return _tObjets;
		} //pour débogage, ne pas supprimer cette ligne!
		public function getTPersos(): Array {
			return _tPersos;
		} //pour débogage, ne pas supprimer cette ligne!
		public function getTTableaux(): Array {
			return _tTousLesTableaux;
		} //pour débogage, ne pas supprimer cette ligne!
		public function getEcranDeJeu(): MovieClip {
			return _ecranDeJeu;
		} //pour débogage, ne pas supprimer cette ligne!
		public function getFacteurTemps(): Number {
			return _facteurTemps;
		} //pour débogage, ne pas supprimer cette ligne!
		public function getZonesTechniquesVisibles(): Boolean {
			return _zonesTechniquesVisibles;
		} //pour débogage, ne pas supprimer cette ligne!
		public function getProchainCombat(): int {
			return _prochainCombat;
		} //pour débogage, ne pas supprimer cette ligne!
		public function getMusiqueOn(): Boolean {
			return _musiqueOn;
		} //pour débogage, ne pas supprimer cette ligne!
		public function getPersoHasExcalibur(): Boolean {
			return _persoHasExcalibur;
		} //pour débogage, ne pas supprimer cette ligne!
		public function getPersoHasInstrumentDagan(): Boolean {
			return _persoHasInstrumentDagan;
		} //pour débogage, ne pas supprimer cette ligne!
		public function getPersoHasDagan(): Boolean {
			return _persoHasDagan;
		}
		public function getPersoHasDelwin(): Boolean {
			return _persoHasDelwin;
		}
		public function getPersoHasDelwinTeleport(): Boolean {
			return _persoHasDelwinTeleport;
		}
		public function getPersoHasCaitlyn(): Boolean {
			return _persoHasCaitlyn;
		}
		public function getCheminForetEstLibre(): Boolean {
			return _cheminForetEstLibre;
		} //pour débogage, ne pas supprimer cette ligne!

		/******************************************************************************
		 *******************************     SETTERS     *******************************
		 ******************************************************************************/
		public function setDistance(nb: Number): void {
			_distance = nb;
		} //pour débogage, ne pas supprimer cette ligne!
		public function setFacteurTemps(nb: Number): void {
			_facteurTemps = nb;
		} //pour débogage, ne pas supprimer cette ligne!
		public function setZonesTechniquesVisibles(choix: Boolean): void {
			_zonesTechniquesVisibles = choix;
		} //pour débogage, ne pas supprimer cette ligne!
		public function setMusiqueOn(choix: Boolean): void {
			_musiqueOn = choix;
		} //pour débogage, ne pas supprimer cette ligne!
		public function setPersoHasExcalibur(etat: Boolean): void {
			_persoHasExcalibur = etat;
		} //pour débogage, ne pas supprimer cette ligne!
		public function setPersoHasInstrumentDagan(etat: Boolean): void {
			_persoHasInstrumentDagan = etat;
		} //pour débogage, ne pas supprimer cette ligne!
		public function setCheminForetEstLibre(etat: Boolean): void {
			_cheminForetEstLibre = etat;
		} //pour débogage, ne pas supprimer cette ligne!
		public function setTObjets(tableau: Array): void {
			_tObjets = tableau;
		} //pour débogage, ne pas supprimer cette ligne!
		public function setPersoHasDagan(state:Boolean): void {
			_persoHasDagan = state;
		}
		public function setPersoHasDelwinTeleport(state:Boolean): void {
			_persoHasDelwinTeleport = state;
		}
		public function setPersoHasDelwin(state:Boolean): void {
			_persoHasDelwin = state;
		}
		public function setPersoHasCaitlyn(state:Boolean): void {
			_persoHasCaitlyn = state;
		}

	} //class
} //package