package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Obstacle extends MovieClip {
		private var _tab:MovieClip;
		private var _jeu:MovieClip;
		private var _zoneCollision:MovieClip; 
		
		public function Obstacle() {
			// CONSTRUCTEUR
			try{
				MovieClip(parent).ajouterObstacle(this);
			} catch(e:Error){ 
				log("BOGUE: L'objet "+this+" demande à son parent "+this.parent+" d'exécuter sa fonction «ajouterObstacles», mais il y a une erreur. ("+e+")", 2);
			} //try+catch
			addEventListener(Event.ADDED_TO_STAGE, init);
		} //function
		
		/******************************************************************************
		Fonction init
		******************************************************************************/		
		private function init(e:Event):void {
			// initialisation des références aux 2 parents:
			_tab = MovieClip(parent);
			_jeu = MovieClip(parent.parent);
			
			gererVisibiliteZone(); //si une zone de collision existe, elle sera masquée à l'utilisateur 
			stage.addEventListener("changementVisibilite", gererVisibiliteZone, true); // pour débogage, ne pas enlever cette ligne
			addEventListener(Event.REMOVED_FROM_STAGE, nettoyer);
		} //init

		/******************************************************************************
		Fonction interagir
		  Elle permet de tester si une interaction doit avoir lieu entre un obstacle et un perso. 
		  Un obstacle de base qui appartient à cette classe ne produit pas d'interaction (ex. une roche), 
		  mais les classes qui découlent de la classe Obstacle (ex. les portes) possèdent leur propre version
		  de la fonction interagir (dans ce cas, c'est celle-là qui a préséance: override)
		******************************************************************************/
		public function interagir(modeTest:Boolean=false):String {
			return ""; // cet obstacle n'est pas interactif(mais il bloque le passage)
		} //interagir
		
		/******************************************************************************
		Fonction definirZoneCollision
		******************************************************************************/		
		public function definirZoneCollision(unClip:MovieClip):void{
			//log(unClip,2);
			_zoneCollision = unClip;
		} //definirZoneCollision
		
		/******************************************************************************
		Fonction getZoneCollision
		******************************************************************************/		
		public function getZoneCollision():MovieClip{
			if(_zoneCollision==null){
				//si l'obstacle ne possède pas de zone précise, il sera entièrement considéré pour la détection
				return this;
			} else {
				//si l'obstacle possède une zone de collision, c'est elle qui sera utilisée pour la détection
				return _zoneCollision;
			} //if+else
		} //getZoneCollision
		
		/******************************************************************************
		Fonction gererVisibiliteZone
		******************************************************************************/		
		private function gererVisibiliteZone(e:Event=null):void{
			if( _zoneCollision!=null ){
				if( _jeu.getZonesTechniquesVisibles() ){
					_zoneCollision.alpha = 0.5;
					_zoneCollision.visible = true; //la zone sera visible, pour fin de débogage
					
				} else {
					_zoneCollision.alpha = 0; //doublement invisible...
					_zoneCollision.visible = false; //dans ce cas, la zone doit être invisible
				} //if+else
			} //if
		} //gererVisibiliteZone

		/******************************************************************************
		Fonction nettoyer
		******************************************************************************/		
		private function nettoyer(e:Event):void{
			stage.removeEventListener("changementVisibilite", gererVisibiliteZone);
		} //nettoyer

	} //class
} //package