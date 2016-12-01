package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class MenuInfo extends MovieClip {
		private var _tPersos:Array;
		private var _jeu:MovieClip;
		
		public function MenuInfo(tPersos) {
			// CONSTRUCTEUR
			_tPersos = tPersos;
			addEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, nettoyer);
		}
		
		/******************************************************************************
		Fonction init
		  Elle initialise les paramètres initiaux et affiche les fiches.
		******************************************************************************/
		private function init(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			_jeu = MovieClip(parent); // initialisation de la référence du parent
			afficherLesFichesPersos();
			afficherLesObjets();
			btRetourMenuInfo.addEventListener(MouseEvent.CLICK, quitterMenuInfo);
		} //init
		
		/******************************************************************************
		Fonction nettoyer
		******************************************************************************/		
		private function nettoyer(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, nettoyer);
			// quelquechose d'autre à faire ici?
		} //nettoyer
		
		/******************************************************************************
		Fonction quitterMenuInfo
		******************************************************************************/		
		private function quitterMenuInfo(e:Event=null):void {
			btRetourMenuInfo.removeEventListener(MouseEvent.CLICK, quitterMenuInfo);
			_jeu.fermerMenuInfo();	
		} //quitterMenuInfo
	
		/******************************************************************************
		Fonction afficherLesFichesPersos
		  Elle affiche une fiche pour chaque personnage avec ses «statistiques».
		******************************************************************************/
		private function afficherLesFichesPersos():void {
			for(var i:int=0; i<4; i++){
				var fiche_mc:MovieClip = MovieClip(getChildByName("fiche"+i));
				if(i<_tPersos.length){
					log(fiche_mc, 3);
					fiche_mc.visible = true
					fiche_mc.identite_mc.gotoAndStop(_tPersos[i].getNom());
					fiche_mc.niveau_txt.text  = _tPersos[i].getNiveau();
					fiche_mc.PV_txt.text  = _tPersos[i].getPVAct()+" / "+_tPersos[i].getPVMax();
					fiche_mc.PM_txt.text  = _tPersos[i].getPMAct()+" / "+_tPersos[i].getPMMax();
					fiche_mc.XP_txt.text  = _tPersos[i].getXPAct()+" / "+_tPersos[i].getXPSuivant();
				} else {
					fiche_mc.visible = false
				} //if+else
			} //for
		} //afficherLesFichesPersos
		
		/******************************************************************************
		Fonction afficherLesObjets
		  Elle affiche une liste des objets obtenus par les personnages.
		******************************************************************************/
		private function afficherLesObjets():void {
			if(_jeu.getTObjets().length>0){
				inventaire_txt.text = "• "+_jeu.getTObjets().join("\n• ");
				if(_jeu.getTObjets().length>4){
					inventaire2_txt.text = "• "+_jeu.getTObjets().slice(5,_jeu.getTObjets().length).join("\n• ");
				}
			} else {
				inventaire_txt.text = "(Aucun objet)";
			} //if+else
			or_txt.text = _jeu.getFortune();
		} //afficherLesObjets
		
		/******************************************************************************
		Fonction frappeClavierMenuInfo
		  Elle est exécutée quand une touche du clavier est enfoncée pendant l'affichage du menu.
		******************************************************************************/
		public function frappeClavierMenuInfo(e:KeyboardEvent):void {
			switch (e.keyCode) {
				case Keyboard.I :
					log("i!", 3);
				case Keyboard.ENTER :
					quitterMenuInfo();
					break;
			} //switch
		} //frappeClavierMenuInfo
		
	} //class
} //package