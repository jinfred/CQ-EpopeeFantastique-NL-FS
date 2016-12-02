package {
	import flash.display.MovieClip;
	import flash.events.Event;

	// Un PNJ est considéré comme un obstacle, afin de permettre l'interaction!
	public class PNJ extends Obstacle {
		private var _absence: Boolean;
		private var _tab: MovieClip;
		private var _jeu: MovieClip;

		private var _REPLIQUE: uint = 0;
		private var _COMBAT: uint = 1;
		private var _OBJET: uint = 2;
		private var _EQUIPIER: uint = 3;
		private var _DISPARITION: uint = 4;

		private var _nomSimple: String;
		private var _nbRencontres: uint = 0;

		public function PNJ() {
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

			_nomSimple = this.name.slice(3, this.name.length - 3); //élimination de "pnj..._mc"
			if (parseInt(_nomSimple.charAt(_nomSimple.length - 1)) > 0) {
				_nomSimple = _nomSimple.slice(0, _nomSimple.length - 1);
			} //élimination des numéros à la fin des noms
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
		  Elle permet de déclencher l'interaction liée au PNJ rencontré (et les dialogues...)
		  (Cette version de la fonction a préséance sur la version de la classe Obstacle.)
		******************************************************************************/
		override public function interagir(modeTest: Boolean = false): String {
			if (!_absence) {
				log("rencontre avec ce PNJ : " + _nomSimple, 2);
				var tSequence: Array;
				var tSequencesPossibles: Array;
				switch (this.name) {
					case "pnjVillageois1_mc":
						//Exemple: une seule réplique simple!
						tSequence = [
							[_REPLIQUE, "Ces puits sont enchantés par la Déesse elle-même."],
							[_REPLIQUE, "Essaie. Tu n’as qu’à jeter une pièce et faire un voeu."],
						];
						break;
					case "pnjVillageois2_mc":
						//Exemple: plusieurs interactions possibles, à chaque rencontre, une seule est sélectionnée au hasard
						tSequencesPossibles = [
							[
								[_REPLIQUE, "Quelle triste vie..."]
							],
							[
								[_REPLIQUE, "On a plus les saisons d'autrefois."]
							],
							[
								[_REPLIQUE, "J'aime bien discuter avec vous, je me sens si seul."]
							]
						];
						tSequence = tSequencesPossibles[Math.floor(Math.random() * tSequencesPossibles.length)]; //choix aléatoire de réplique
						break;
					case "pnjVillageois3_mc":
						//Exemple: répliques de type «ping pong» (avec réponse du héros!)
						tSequence = [
							[_REPLIQUE, "Quelle belle journée pour prendre de l’air!"],
						];
						break;
					case "pnjVillageois4_mc":
						//Exemple: plusieurs répliques, qui sont toutes affichées de manière séquentielle (à chaque rencontre)
						tSequence = [
							[_REPLIQUE, "Je rêve du jour où nous pourrons vivre paisiblement à nouveau."],
						];
						break;
					case "pnjVillageois5_mc":
						//Exemple: plusieurs interactions, affichées à raison d'une par rencontre (en ordre, répétition au besoin)
						tSequencesPossibles = [
							[
								[_REPLIQUE, "J'ai été entraineur de combat dans mon jeune temps... \n Je peux vous donner des conseils... Revenez me voir si ça vous intéresse!"]
							],
							[
								[_REPLIQUE, "Les combats demandent de la force et de la stratégie."]
							],
							[
								[_REPLIQUE, "Quand un nouvel aventurier veut gagner de l'expérience, il doit se soigner entre ses combats."]
							]
						];
						tSequence = tSequencesPossibles[_nbRencontres % tSequencesPossibles.length]; //choix d'une réplique selon «l'évolution» de la relation!
						log("DISCUSSION avec " + this.name + " (nombre de rencontres = " + _nbRencontres + ")", 2);

						break;
					case "pnjVillageois6_mc":
						//Exemple: forcer le nom affiché du PNJ
						_nomSimple = "Martin";
						tSequence = [
							[_REPLIQUE, "Jadis, naguère, nous formions des groupes pour vaincre le mal."]
						];
						break;
					case "pnjVillageois7_mc":
						tSequence = [
							[_REPLIQUE, "J'ai entendu parler d'une chamane qui peut guérir les blessures."],
							[_REPLIQUE, "On raconte qu'elle cultive des patates dans la forêt!"]
						];
						break;
					case "pnjVillageois8_mc":
						//Exemple: transmission d'un objet dans la séquence du dialogue et disparition du PNJ
						tSequence = [
							[_REPLIQUE, "On dit qu’en dehors de ce village, il y a un temple qui peut soigner toutes tes blessures…"],
							[_REPLIQUE, "Tu imagine? Fini les maux de dos…"],
						];
						break;
					case "pnjGarde1_mc":
						tSequence = [
							[_REPLIQUE, "J'aurais tellement aimé vous accompagner..."],
							[_REPLIQUE, "Avant, j'étais moi aussi un aventurier, \npuis j'ai pris une flèche dans le genou..."]
						];
						break;
					case "pnjGarde2_mc":
						tSequence = [
							[_REPLIQUE, "Ne me demandez pas de vous accompagner, moi je fais simplement mon travail..."]
						];
						break;
					case "pnjGarde3_mc":
						tSequence = [
							[_REPLIQUE, "Nul doute, si nous avions une auberge, cette épopée serait fantastique..."]
						];
						break;
					case "pnjGarde4_mc":
						tSequence = [
							[_REPLIQUE, "La fille du roi est redoutable!"]
						];
						break;
					case "pnjSentinelle_mc":
						tSequence = [
							[_REPLIQUE, "Vous courez de grands dangers en dehors de ces murs..."]
						];
						break;
					case "pnjVendeur_mc":
						tSequence = [
							[_REPLIQUE, "J'aimerais vous vendre des armes..."],
							[_REPLIQUE, "Oh oui! Quelle bonne idée!", "Spero"],
							[_REPLIQUE, "Malheureusement, j'ai perdu la clé de mon magasin."]
						];
						break;
					case "pnjMaman_mc":
						tSequence = [
							[_REPLIQUE, "Tout va bien, mon enfant?", "Maman"],
							[_REPLIQUE, "Tu marmonnais dans ton sommeil…", "Maman"]
						];
						break;
					case "pnjRoi_mc":
						//Exemple: séquences de répliques différentes selon une condition préalable
						if (_jeu.verifierAbsence("pnjNova_mc") == false) {
							//si Nova n'est pas dans la liste d'absence, le roi propose sa participation
							tSequence = [
								[_REPLIQUE, "Torgul a détruit notre armée, nous sommes maintenant pratiquement sans défense..."],
								[_REPLIQUE, "Je crains que notre fin soit proche... \nSi vous souhaitez tenter votre chance, la princesse Nova pourrait vous accompagner."]
							];
						} else {
							tSequence = [
								[_REPLIQUE, "Puisque ma fille vous accompagne, je vous donne un peu d'or."],
								[_OBJET, "Or", 10]
							]; //ajoute de l'or au trésor du joueur...
						} //if+else
						break;


					case "pnjGardeDuPont_mc":
						_nomSimple = "Sous-chef";
						tSequence = [
							[_REPLIQUE, "Je garde ce pont!"],
							[_REPLIQUE, "...", "Spero"],
							[_REPLIQUE, "Vous ne passerez pas!"],
							[_COMBAT, "SousChef1"],
							[_DISPARITION, false]
						];
						break;
					case "pnjTorgul_mc":
						tSequence = [
							[_REPLIQUE, "Alors c’est toi, Spero. Celui dont tout le monde parle."],
							[_REPLIQUE, "Celui qui a su sortir Excalibur de son piédestal."],
							[_REPLIQUE, "Tu n’es qu’un gamin!"],
							[_REPLIQUE, "Et ton histoire s’arrête là!"],
							[_REPLIQUE, "Prépare-toi à te mourrir, gamin !"],
							[_COMBAT, "Chef"],
							[_DISPARITION, false]
						];
						break;

						//Dialogues personnalisés - DÉBUT

					case "pnjLostWoodsDagan1_mc":
						//Exemple: répliques de type «ping pong» (avec réponse du héros!)
						tSequence = [
							[_REPLIQUE, "D’accord, alors si je me souviens bien il faut aller… par là !", "Dagan"],
							[_DISPARITION, false]
						];
						break;

					case "pnjLostWoodsDagan2_mc":
						//Exemple: répliques de type «ping pong» (avec réponse du héros!)
						tSequence = [
							[_REPLIQUE, "Ou bien par là ?", "Dagan"],
							[_DISPARITION, false]
						];
						break;

					case "pnjLostWoodsDagan3_mc":
						//Exemple: répliques de type «ping pong» (avec réponse du héros!)
						tSequence = [
							[_REPLIQUE, "Mmmm….", "Dagan"],
							[_DISPARITION, false]
						];
						break;

					case "pnjLostWoodsDagan4_mc":
						//Exemple: répliques de type «ping pong» (avec réponse du héros!)
						tSequence = [
							[_REPLIQUE, "Je croyais que…", "Dagan"],
							[_DISPARITION, false]
						];
						break;

					case "pnjLostWoodsDagan5_mc":
						//Exemple: répliques de type «ping pong» (avec réponse du héros!)
						tSequence = [
							[_REPLIQUE, "Par… ici ?", "Dagan"],
							[_DISPARITION, false]
						];
						break;

					case "pnjLostWoodsDagan6_mc":
						//Exemple: répliques de type «ping pong» (avec réponse du héros!)
						tSequence = [
							[_REPLIQUE, "Bon, nous y voilà !", "Dagan"],
							[_REPLIQUE, "Oh, non ! Le pont à été détruit… C’était le seul chemin !", "Dagan"],
							[_DISPARITION, false]
						];
						break;

					case "pnjMarchand1_mc":
						//Exemple: répliques de type «ping pong» (avec réponse du héros!)
						tSequence = [
							[_REPLIQUE, "Si tu veux avoir une chance de vaincre Mordred, tu dois être bien équipé."],
							[_REPLIQUE, "Justement, regarde ce que j’ai…"],
						];
						break;

					case "pnjAubergiste_mc":
						//Exemple: répliques de type «ping pong» (avec réponse du héros!)
						tSequence = [
							[_REPLIQUE, "Eh bien, on dirait que Dagan à encore perdu son instrument... Le pauvre !"],
							[_REPLIQUE, "Alors c’est vrai ce qu’on dit… Tu va vraiment quitter le village ?"],
						];
						break;

					case "pnjLostWoodsDelwin_mc":
						//Exemple: répliques de type «ping pong» (avec réponse du héros!)
						tSequence = [
							[_REPLIQUE, "Hey, les garçons ! Vous cherchez un moyen pour traverser ?", "Delwin"],
							[_REPLIQUE, "Oui, mais le pont est détruit… C’était le seul moyen !", "Dagan"],
							[_REPLIQUE, "Il y un toujours un moyen !", "Delwin"],
							[_REPLIQUE, "Ah bon, comment ?", "Dagan"],
							[_REPLIQUE, "C’est bien simple, je vais vous téléporter de l’autre côté.", "Delwin"],
							[_REPLIQUE, "Tu es dingue !? L’as-tu déjà fait ?", "Dagan"],
							[_REPLIQUE, "Bien sûr que je l’ai déjà fait ! En quelque sorte…", "Delwin"],
							[_REPLIQUE, "D’accord… si tu en est certaine…", "Dagan"],
							[_REPLIQUE, "Bon… allons-y !", "Delwin"],
							[_DISPARITION, false]
						];
						break;

					case "pnjMarchand2_mc":
						//Exemple: répliques de type «ping pong» (avec réponse du héros!)
						tSequence = [
							[_REPLIQUE, "Un aventurier bien équipé est un bon aventurier! Surtout si tu achètes ma marchandise!"],
						];
						break;

					case "pnjMarchand3_mc":
						//Exemple: répliques de type «ping pong» (avec réponse du héros!)
						tSequence = [
							[_REPLIQUE, "Je pense m’être égaré en essayant de trouver le château."],
							[_REPLIQUE, "Veux tu regarder ma marchandise pendant que j’essaie de retrouver mon chemin?"],
							[_REPLIQUE, "Attention, je t’ai à l’oeil!"],
						];
						break;

					case "pnjAubergiste2_mc":
						//Exemple: répliques de type «ping pong» (avec réponse du héros!)
						tSequence = [
							[_REPLIQUE, "Qu’est-ce que je te sers?"],
							[_REPLIQUE, "Il y a bien des rumeurs qui circulent…"],
							[_REPLIQUE, "On dit qu'un jeune héros va tenter de vaincre Mordred."],
							[_REPLIQUE, "Un autre gamin qui cours à sa perte..."],
						];
						break;

					case "pnjForgeron_mc":
						//Exemple: répliques de type «ping pong» (avec réponse du héros!)
						tSequence = [
							[_REPLIQUE, "Passe ton chemin, gamin."],
							[_REPLIQUE, "Je n’ai pas d’armure pour ta taille..."],
						];
						break;

					case "pnjFortis_mc":
						//Exemple: répliques de type «ping pong» (avec réponse du héros!)
						tSequence = [
							[_REPLIQUE, "Qu’est-ce qui s’est passé ?", "Dagan"],
							[_REPLIQUE, "Oh… non ! Ce n’était pas supposé se passer comme ça !", "Delwin"],
							[_REPLIQUE, "Mais où sommes-nous ?", "Delwin"],
							[_REPLIQUE, "J’en sais rien… essayons de retrouver notre chemin.", "Dagan"],
							[_EQUIPIER],
							[_DISPARITION, false]
						];
						break;

					case "pnjNova_mc":
						//Exemple: répliques de type «ping pong» (avec réponse du héros!)
						tSequence = [
							[_REPLIQUE, "J'ai oublié mes dialogues... Aidez-moi !", "Caitlyn"],
							[_EQUIPIER],
							[_DISPARITION, false]
						];
						break;

					case "pnjGuardForet_mc":
						if (_jeu.getPersoHasExcalibur() == true) {
							tSequence = [
								[_REPLIQUE, "Mais… C’est…", "Garde"],
								[_REPLIQUE, "EXCALIBUR?!", "Garde"],
								[_REPLIQUE, "Cela veut dire que tu es le héros qui va sauver Kylemore?", "Garde"],
								[_REPLIQUE, "Cette forêt mène directement au château du roi. C’est le seul chemin.", "Garde"],
								[_REPLIQUE, "Attention, cette forêt est dangereuse et pleine de monstres.", "Garde"],
								[_REPLIQUE, "Beaucoup de gens se perdent et on ne les retrouve plus jamais…", "Garde"],
								[_DISPARITION, false]
							];
							_jeu.setCheminForetEstLibre(true);
							var zoneObstacle = _tab.getChildByName("obstacleGuard_mc");
							//_tab.removeChild(zoneObstacle);
							zoneObstacle.y += 200;
							break;
						} else {
							tSequence = [
								[_REPLIQUE, "Olà, gamin!", "Garde"],
								[_REPLIQUE, "Personne n’a le droit d’entrer dans ces bois. C’est bien trop dangereux.", "Garde"],
								[_REPLIQUE, "Seuls ceux qui ont une épée ont une chance de s’en sortir.", "Garde"],
								[_REPLIQUE, "Reviens avec Excalibur elle-même et je te laisse passer.", "Garde"],
								[_REPLIQUE, "Mais tu ne peux pas avoir une telle épée, tu n’es qu’un gamin.", "Garde"],
								[_REPLIQUE, "HA! HA! HA!", "Garde"],
							];
							break;
						}
						break;

					case "pnjExaclibur_mc":
						if (_jeu.getPersoHasExcalibur() == false) {
							tSequence = [
								[_REPLIQUE, "Héros, les temps sont durs", "L'épée magique Excalibur"],
								[_REPLIQUE, "Nous comptons tous sur toi pour ramener la paix au monde de Kylemore", "L'épée magique Excalibur"],
								[_REPLIQUE, "Avec mon aide, et des camarades... nous vaincrons Mordred.", "L'épée magique Excalibur"],
								[_OBJET, "Excalibur", 1],
							];
							_jeu.setPersoHasExcalibur(true);
							break;
						}else{
							return "Absent";
						}

						//_jeu.setPersoHasExcalibur(true);
						break;

					case "pnjLucem_mc":
						if (_jeu.getPersoHasInstrumentDagan() == false) {
							tSequence = [
								[_REPLIQUE, "Oh, hé ! Tu crois pouvoir m’aider ?", "Dagan"],
								[_REPLIQUE, "Tu vois, j’ai perdu mon instrument l’autre jour…", "Dagan"],
								[_REPLIQUE, "Je crois l’avoir oublié dans la forêt…", "Dagan"],
								[_REPLIQUE, "Mais bon, assez parlé de moi ! Toi, tu fais quoi dans une place comme celle-ci ?", "Dagan"],
								[_REPLIQUE, "Tu veux traverser la forêt !? C’est trop dangereux !", "Dagan"],
								[_REPLIQUE, "Moi ? Je la connais comme le fond de ma poche.", "Dagan"],
								[_REPLIQUE, "Tu sais quoi ? Aide moi à retrouver mon instrument et je t’aiderai à traverser la forêt.", "Dagan"],
							];
							break;
						} else{
							tSequence = [
								[_REPLIQUE, "Oh, génial ! Tu l’a retrouvé !", "Dagan"],
								[_REPLIQUE, "Eh bien, je t’ai fait une promesse. Allons-y !", "Dagan"],
								[_EQUIPIER],
								[_DISPARITION, false]
							];
							//trace("Essayons " + _jeu.getTObjets().indexOf("Instrument de Dagan", 0));
							//trace(_jeu.getTObjets());
							var posInstrument: int = _jeu.getTObjets().indexOf("Instrument de Dagan", 0);
							//var nouveauTableauTObjets:Array = (_jeu.getTObjets().splice(posInstrument, 1));
							_jeu.setTObjets(_jeu.getTObjets().splice(posInstrument, 1));
							//trace(_jeu.getTObjets());
							trace(_jeu.getTObjets().splice(posInstrument, 1));
							break;
						}

						break;


						//Dialogues personnalisés - FIN
					default:
						if (modeTest) {
							return "Erreur";
						} //si appelé par la fn verifierSiValide(), on quitte avec erreur
						tSequence = [
							[_REPLIQUE, "Je ne sais plus qui je suis, je suis tout déboussolé."]
						];
						break;
				} //switch

				if (modeTest) {
					return "Ok";
				} //si appelé par la fn verifierSiValide(), on quitte sans erreur

				if (_jeu.declencherDialogue(tSequence, this)) {
					_nbRencontres++;
				} //si deClencherDialogue retourne true, le dialogue a été déclenché donc on incrémente _nbRencontres

				return "Dialogue";
			} //if principal (n'est pas absent)
			return "Absent"; //le PNJ est absent (donc pas d'interaction)
		} //interagir

		/******************************************************************************
		 *******************     FONCTIONS DE TESTS AUTOMATISÉS     ********************
		 ******************************************************************************/
		public function verifierSiValide(): Boolean {
			var resultat: Boolean = true; //le test est un valide, jusqu'à preuve du contraire!

			//### Les règles à tester pour valider le nom de l'instance ###

			//#1. le nom doit débuter par "pnj":
			if (name.slice(0, 3) != "pnj") {
				resultat = false;
			} //c'est un échec si le nom ne débute pas comme prévu...

			//#2. le nom doit se terminer par "_mc"
			if (name.slice(name.length - 3) != "_mc") {
				resultat = false;
			} //c'est un échec si le nom ne se termine pas comme prévu...

			//#3. le personnage doit avoir une séquence de dialogues 
			var modeDeTest: Boolean = true;
			if (interagir(modeDeTest) == "Erreur") {
				resultat = false;
			} //c'est un échec si aucun dialogue particulier n'a été prévu

			return resultat;
		} //verifierSiValide

		/******************************************************************************
		 *******************************     GETTERS     *******************************
		 ******************************************************************************/
		public function getNomSimple(): String {
			return _nomSimple;
		}

	} //class
} //package