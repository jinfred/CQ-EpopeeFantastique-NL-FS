package {
	import flash.display.MovieClip;
	import flash.events.Event;

	// Un PNJ est considéré comme un obstacle, afin de permettre l'interaction!
	public class PNJ extends Obstacle {
		private var _absence:Boolean;
		private var _tab:MovieClip;
		private var _jeu:MovieClip;
		
		private var _REPLIQUE:uint=0;
		private var _COMBAT:uint=1;
		private var _OBJET:uint=2;
		private var _EQUIPIER:uint=3;
		private var _DISPARITION:uint=4;
		
		private var _nomSimple:String;
		private var _nbRencontres:uint=0;

		public function PNJ() {
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
			
			_absence = _jeu.verifierAbsence(this.name); //true = le nom est dans la liste des absences
			visible = !(_absence); //invisible si absent, visible si présent
			
			_nomSimple = this.name.slice(3, this.name.length-3); //élimination de "pnj..._mc"
			if(parseInt(_nomSimple.charAt(_nomSimple.length-1))>0){_nomSimple=_nomSimple.slice(0,_nomSimple.length-1);} //élimination des numéros à la fin des noms
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
		  Elle permet de déclencher l'interaction liée au PNJ rencontré (et les dialogues...)
		  (Cette version de la fonction a préséance sur la version de la classe Obstacle.)
		******************************************************************************/
		override public function interagir(modeTest:Boolean=false):String {
			if(!_absence){
				log("rencontre avec ce PNJ : "+_nomSimple, 2);
				var tSequence:Array;
				var tSequencesPossibles:Array;
				switch (this.name) {
					case "pnjVillageois1_mc":
						//Exemple: une seule réplique simple!
						tSequence=[[_REPLIQUE, "Je rêve du jour où nous pourrons vivre paisiblement à nouveau."]];
						break;
					case "pnjVillageois2_mc":
						//Exemple: plusieurs interactions possibles, à chaque rencontre, une seule est sélectionnée au hasard
						tSequencesPossibles = [
							[ [_REPLIQUE, "Quelle triste vie..."] ], 
							[ [_REPLIQUE, "On a plus les saisons d'autrefois."] ], 
							[ [_REPLIQUE, "J'aime bien discuter avec vous, je me sens si seul."] ] 
						];
						tSequence= tSequencesPossibles[ Math.floor( Math.random()*tSequencesPossibles.length ) ]; //choix aléatoire de réplique
						break;
					case "pnjVillageois3_mc":
						//Exemple: répliques de type «ping pong» (avec réponse du héros!)
						tSequence=[
							[_REPLIQUE, "Vite, sauvez notre village! Vous êtes notre seul espoir..."],
							[_REPLIQUE, "Eh... Ok!", "Spero"]
						];
						break;
					case "pnjVillageois4_mc":
						//Exemple: plusieurs répliques, qui sont toutes affichées de manière séquentielle (à chaque rencontre)
						tSequence=[
							[_REPLIQUE, "Si seulement nous avions un temple..."],
							[_REPLIQUE, "Un endroit pour nous ressourcer..."],
							[_REPLIQUE, "Un genre de lieu magique..."],
							[_REPLIQUE, "De préférence avec de la musique douce..."]
						];
						break;
					case "pnjVillageois5_mc":
						//Exemple: plusieurs interactions, affichées à raison d'une par rencontre (en ordre, répétition au besoin)
						tSequencesPossibles = [ 
							[ [_REPLIQUE, "J'ai été entraineur de combat dans mon jeune temps... \n Je peux vous donner des conseils... Revenez me voir si ça vous intéresse!"] ], 
							[ [_REPLIQUE, "Les combats demandent de la force et de la stratégie."] ], 
							[ [_REPLIQUE, "Quand un nouvel aventurier veut gagner de l'expérience, il doit se soigner entre ses combats."] ] 
						];
						tSequence= tSequencesPossibles[ _nbRencontres % tSequencesPossibles.length ]; //choix d'une réplique selon «l'évolution» de la relation!
						log("DISCUSSION avec " + this.name + " (nombre de rencontres = " + _nbRencontres + ")", 2); 

						break;
					case "pnjVillageois6_mc":
						//Exemple: forcer le nom affiché du PNJ
						_nomSimple = "Martin";
						tSequence=[[_REPLIQUE, "Jadis, naguère, nous formions des groupes pour vaincre le mal."]];
						break;
					case "pnjVillageois7_mc":
						tSequence=[
							[_REPLIQUE, "J'ai entendu parler d'une chamane qui peut guérir les blessures."], 
							[_REPLIQUE, "On raconte qu'elle cultive des patates dans la forêt!"]
						];
						break;
					case "pnjVillageois8_mc":
						//Exemple: transmission d'un objet dans la séquence du dialogue et disparition du PNJ
						tSequence=[
							[_REPLIQUE, "Prenez vite cette patate pour vous encourager dans votre aventure."], 
							[_OBJET, "Patate"],
							[_REPLIQUE, "Je dois partir maintenant... j'ai un ragoût parmentier sur le feu."],
							[_DISPARITION]
						];
						break;
					case "pnjGarde1_mc":
						tSequence=[
							[_REPLIQUE, "J'aurais tellement aimé vous accompagner..."],
							[_REPLIQUE, "Avant, j'étais moi aussi un aventurier, \npuis j'ai pris une flèche dans le genou..."]
						];
						break;
					case "pnjGarde2_mc":
						tSequence=[
							[_REPLIQUE, "Ne me demandez pas de vous accompagner, moi je fais simplement mon travail..."]
						];
						break;
					case "pnjGarde3_mc":
						tSequence=[
							[_REPLIQUE, "Nul doute, si nous avions une auberge, cette épopée serait fantastique..."]
						];
						break;
					case "pnjGarde4_mc":
						tSequence=[
							[_REPLIQUE, "La fille du roi est redoutable!"]
						];
						break;
					case "pnjSentinelle_mc":
						tSequence=[
							[_REPLIQUE, "Vous courez de grands dangers en dehors de ces murs..."]
						];
						break;
					case "pnjVendeur_mc":
						tSequence=[
							[_REPLIQUE, "J'aimerais vous vendre des armes..."],
							[_REPLIQUE, "Oh oui! Quelle bonne idée!", "Spero"],
							[_REPLIQUE, "Malheureusement, j'ai perdu la clé de mon magasin."]
						];
						break;
					case "pnjMaman_mc":
						tSequence=[
							[_REPLIQUE, "Bonjour mon beau Spero! J'ai de la bonne soupe pour toi.\nPrends un petit bol, ça va te faire du bien."],
							[_REPLIQUE, "(C'est vrai, vous vous sentez un peu mieux!)", "Points de vie"]
						];
						_jeu.soigner(2); //tous les personnages récupèrent tous leurs points
						break;
					case "pnjRoi_mc":
						//Exemple: séquences de répliques différentes selon une condition préalable
						if(_jeu.verifierAbsence("pnjNova_mc")==false){
							//si Nova n'est pas dans la liste d'absence, le roi propose sa participation
							tSequence=[
								[_REPLIQUE, "Torgul a détruit notre armée, nous sommes maintenant pratiquement sans défense..."],
								[_REPLIQUE, "Je crains que notre fin soit proche... \nSi vous souhaitez tenter votre chance, la princesse Nova pourrait vous accompagner."]
							];
						} else {
							tSequence=[
								[_REPLIQUE, "Puisque ma fille vous accompagne, je vous donne un peu d'or."], 
								[_OBJET, "Or", 10]
							];//ajoute de l'or au trésor du joueur...
						} //if+else
						break;
					case "pnjNova_mc":
						//Exemple: ajout d'un personnage dans l'équipe
						tSequence=[
							[_REPLIQUE, "Je refuse d'abandonner devant ce monstre."],
							[_REPLIQUE, "Je vous accompagnerai jusqu'au bout!"],
							[_EQUIPIER],
							[_DISPARITION]
						];
						break;
					case "pnjLucem_mc":
						tSequence=[
							[_REPLIQUE, "Qui êtes-vous? Que me voulez-vous?"],
							[_REPLIQUE, "Je m'appelle Spero. Je veux vaincre Torgul.", "Spero"],
							[_REPLIQUE, "Oh! Je m'appelle Lucem, je suis chamane. Je peux soigner avec ma magie."],
							[_REPLIQUE, "Nous aurions grand besoin de votre aide...", "Spero"], 
							[_REPLIQUE, "C'est d'accord. Je vais vous accompagner dans votre épopée et je vais même partager mes patates."],
							[_EQUIPIER],
							[_DISPARITION]
						];
						_jeu.noterAbsence("barriere_1"); // pour masquer la barriere lors du prochain affichage du tableau
						break;
					case "pnjFortis_mc":
						tSequence=[
							[_REPLIQUE, "Bonjour, je suis Fortis, je peux vous aider avec la puissance de ma magie!"],
							[_EQUIPIER],
							[_DISPARITION]
						];
						break;
					case "pnjGardeDuPont_mc":
						_nomSimple = "Sous-chef";
						tSequence=[
							[_REPLIQUE, "Je garde ce pont!"],
							[_REPLIQUE, "...", "Spero"],
							[_REPLIQUE, "Vous ne passerez pas!"], 
							[_COMBAT, "SousChef1"],
							[_DISPARITION, false]
						];
						break;
					case "pnjTorgul_mc":
						tSequence=[
							[_REPLIQUE, "Je suis Torgul!\nVous osez me défier?\nJe vais vous écraser!"], 
							[_COMBAT, "Chef"],
							[_DISPARITION, false]
						];
						break;
					default:
						if( modeTest ){ return "Erreur"; } //si appelé par la fn verifierSiValide(), on quitte avec erreur
						tSequence=[[_REPLIQUE, "Je ne sais plus qui je suis, je suis tout déboussolé."]];
						break;
				} //switch
				
				if( modeTest ){ return "Ok"; } //si appelé par la fn verifierSiValide(), on quitte sans erreur
				
				if( _jeu.declencherDialogue(tSequence, this) ){ _nbRencontres++; } //si deClencherDialogue retourne true, le dialogue a été déclenché donc on incrémente _nbRencontres
				
				return "Dialogue";
			} //if principal (n'est pas absent)
			return "Absent"; //le PNJ est absent (donc pas d'interaction)
		} //interagir
		
		/******************************************************************************
		*******************     FONCTIONS DE TESTS AUTOMATISÉS     ********************
		******************************************************************************/
		public function verifierSiValide():Boolean{ 
			var resultat:Boolean = true; //le test est un valide, jusqu'à preuve du contraire!
			
			//### Les règles à tester pour valider le nom de l'instance ###
			
			//#1. le nom doit débuter par "pnj":
			if(name.slice(0,3)!="pnj"){ resultat = false; } //c'est un échec si le nom ne débute pas comme prévu...
			
			//#2. le nom doit se terminer par "_mc"
			if(name.slice(name.length-3) != "_mc"){ resultat = false; } //c'est un échec si le nom ne se termine pas comme prévu...
			
			//#3. le personnage doit avoir une séquence de dialogues 
			var modeDeTest:Boolean = true;
			if( interagir(modeDeTest)=="Erreur" ){ resultat = false; } //c'est un échec si aucun dialogue particulier n'a été prévu
			
			return resultat;
		} //verifierSiValide

		/******************************************************************************
		*******************************     GETTERS     *******************************
		******************************************************************************/
		public function getNomSimple():String{ return _nomSimple; }

	} //class
} //package