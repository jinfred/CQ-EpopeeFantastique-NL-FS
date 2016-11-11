package  {
	import flash.display.MovieClip;
	import flash.events.Event;
    import flash.geom.Point;
	
	public class Etre extends MovieClip {
		protected var _nom:String; //nom de l'Etre
		protected var _PVAct:int; // ses points de vie courants
		protected var _PVMax:int; // ses points de vie maximums
		protected var _PMAct:int; // ses points de magie courants
		protected var _PMMax:int; // ses points de magie maximums
		protected var _baseAtt:int; // son attaque de base
		protected var _baseDef:int; // sa défense de base
		protected var _baseAttMag:int; // son attaque magique de base
		protected var _baseDefMag:int; // sa défense magique de base
		protected var _baseVitesse:int; // sa vitesse de base
		public var pVitesseRonde:int; // sa vitesse pour cette ronde d'attaque (variable publique pour permettre un tri sur le Array des attaquants dans combat.as)
		protected var _type:String; // le type : perso ou monstre
		protected var _stats_mc:MovieClip; // le MC des points
		
		//protected var niveauPerso:Number = Perso.getNiveau();  // Le niveau du personnage
		//protected var multiplicateurStats:Number = niveauPerso*1.10;  // Le niveau du personnage multiplié par 1.10
		
		
		public function Etre(){ } // CONSTRUCTEUR
		
		public function initParamEtre(nom:String, PVAct:int, PVMax:int, PMAct:int, PMMax:int, baseAtt:int, baseDef:int, baseAttMag:int, baseDefMag:int, baseVitesse:int, type:String, niveau:int=1){
		var mutliplicateurNiveau = 1+(niveau-1*0.1);
			_nom=nom;
			_PVAct=PVAct;
			_PVMax=Math.floor(PVMax * mutliplicateurNiveau);
			_PMAct=PMAct;
			_PMMax=Math.floor(PMMax * mutliplicateurNiveau);
			_baseAtt=Math.floor(baseAtt * mutliplicateurNiveau);
			_baseDef=Math.floor(baseDef * mutliplicateurNiveau);
			_baseAttMag=Math.floor(baseAttMag * mutliplicateurNiveau);
			_baseDefMag=Math.floor(baseDefMag * mutliplicateurNiveau);
			_baseVitesse=Math.floor(baseVitesse * mutliplicateurNiveau);
			_type=type;
			addEventListener(Event.REMOVED_FROM_STAGE, nettoyer)
		} //initParamEtre
		
		protected function nettoyer(e:Event):void{
			log("MÉNAGE dans ÊTRE", 3);
			enleverStats();
		} //nettoyer
		
		/******************************************************************************
		Fonction placerCorps
		  Elle permet de placer/deplacer le clip de l'Etre.
		******************************************************************************/
		public function placerCorps(laPos:Point):void {
			x = laPos.x; y = laPos.y;
			if(getPVAct() == 0 && _type == "Perso"){ gotoAndStop("Mort"); } //ici pourquoi seulement perso?
		} //placerCorps
		
		/******************************************************************************
		Fonction jouerAnim
		  Elle permet de jouer une animation du clip de l'Etre.
		******************************************************************************/
		public function jouerAnim(animDemandee:String):void {
			if(currentLabel!=animDemandee){
				//si l'animation n'est pas déjà en cours...
				if(verifierLabelExiste(animDemandee)){ 
					//l'anim existe
					gotoAndPlay(animDemandee);
				} else {
					//l'anim n'existe pas
					log(("L'animation «"+animDemandee+"» n'existe pas dans le clip de "+_nom+" (le frame 1 sera montré par défaut)."), 2);
					if(currentFrame!=1){ gotoAndPlay(1); } //on joue le frame par défaut, si on y est pas déjà...
				} //if+else
			} else {
				play(); //au cas où l'anim serait arrêtée
			} //if+else
		} //jouerAnim
		
		/******************************************************************************
		Fonction verifierLabelExiste
		  Elle permet de vérifier si un label existe (true) ou pas (false)
		******************************************************************************/
		public function verifierLabelExiste(labelDemande:String):Boolean {
			for(var i:uint=0; i<currentLabels.length; i++){
				if(currentLabels[i].name == labelDemande){ return true; }
			}
			return false;
		} //verifierLabelExiste

		/******************************************************************************
		Fonction dimensionnerCorps
		  Elle permet de donner la taille souhaitée au clip de l'être (taille 1.0=100%)
		******************************************************************************/
		public function dimensionnerCorps(taille:Number):void {
			scaleX = taille; scaleY = taille;
		} //dimensionnerCorps
		
		/******************************************************************************
		Fonction etablirVitesseRonde
		  Elle permet de déterminer la vitesse d'action pour une ronde d'attaques.
		******************************************************************************/
		public function etablirVitesseRonde() {
			pVitesseRonde = getBaseVitesse()+Math.floor(Math.random()*100);
		} //etablirVitesseRonde
				
		/******************************************************************************
		Fonction etablirAttRonde
		  Elle permet de déterminer la puissance de l'attaque pour la ronde en cours.
		******************************************************************************/
		public function etablirAttRonde():int {
			return(getBaseAtt()+Math.floor(Math.random()*10)*2);
		} //etablirAttRonde
		
		/******************************************************************************
		Fonction etablirAttMagRonde
		  Elle permet de déterminer la puissance de l'attaque magique pour la ronde en cours.
		******************************************************************************/
		public function etablirAttMagRonde(facteur:Number = 2):int {
			return(int(getBaseAttMag()+Math.floor(Math.random()*10)*facteur));
		} //etablirAttMagRonde
			
		/******************************************************************************
		Fonction blesser
		  Elle permet d'affecter la santé en lui infligeant des dommages et de vérifier s'il est mort.
		******************************************************************************/
		public function blesser(nbPoints:Number):void {
			setPVAct(getPVAct()-nbPoints);
			if(getPVAct()<=0) { gotoAndPlay("Mort"); } //afficher le corps mort au besoin
			afficherStats();
		} //blesser
		
		/******************************************************************************
		Fonction guerir
		  Elle permet d'augmenter la santé, sans dépasser le maximum.
		******************************************************************************/
		public function guerir(nbPoints:Number, peutRessusciter:Boolean=false):void {
			if(peutRessusciter || getPVAct()>0){
				setPVAct(getPVAct()+nbPoints); //avec setPVAct, impossible de dépasser PVMax
			} //if
			afficherStats();
		} //guerir
				
		/******************************************************************************
		Fonction placerStats
		******************************************************************************/		
		public function placerStats():void{
			if(_type == "Perso"){ // temporaire: il faudrait ajouter une mécanique pour les monstres
				_stats_mc = new Stats();
				_stats_mc.x = 45; _stats_mc.y = 0;
				addChild(_stats_mc);
				afficherStats();
			} //if
		} //placerStats

		/******************************************************************************
		Fonction enleverStats
		******************************************************************************/		
		public function enleverStats():void{
			if( _stats_mc != null ){ //ne pas enlever les points s'ils ne sont pas affichés...
				removeChild(_stats_mc);
				_stats_mc = null;
			} //if
		} //enleverStats

		/******************************************************************************
		Fonction afficherStats
		******************************************************************************/		
		public function afficherStats():void{
			if( _stats_mc != null ){ //ne pas essayer d'afficher si les points ne sont pas placés!
				_stats_mc.PV_txt.text = _PVAct+" / "+_PVMax;
				_stats_mc.PM_txt.text = _PMAct+" / "+_PMMax;
			} //if
		} //afficherStats

		/******************************************************************************
		*******************************     GETTERS     *******************************
		******************************************************************************/
		public function getNom():String{ return _nom; }
		public function getPVAct():int{ return _PVAct; }
		public function getPVMax():int{ return _PVMax; }
		public function getPMAct():int{ return _PMAct; }
		public function getPMMax():int{ return _PMMax; }
		public function getBaseAtt():int{ return _baseAtt; }
		public function getBaseDef():int{ return _baseDef; }
		public function getBaseAttMag():int{ return _baseAttMag; }
		public function getBaseDefMag():int{ return _baseDefMag; }
		public function getBaseVitesse():int{ return _baseVitesse; }
		public function getType():String{ return _type; }
				
		/******************************************************************************
		*******************************     SETTERS     *******************************
		******************************************************************************/
		public function setPVAct(PVAct:int):void {
			if( PVAct < 0 ){ PVAct = 0; } //permet d'empêcher d'être mort avec une valeur négative
			if( PVAct > getPVMax() ){ PVAct = getPVMax(); } // si ça dépasse le max, on applique le max
			_PVAct = PVAct;
		} //setPVAct
		public function setPVMax(PVMax:int):void{ _PVMax = PVMax; }
		public function setPMAct(PMAct:int):void{ _PMAct = PMAct; }
		public function setPMMax(PMMax:int):void{ _PMMax = PMMax; }
		public function setBaseAtt(baseAtt:int):void{ _baseAtt = baseAtt; }
		public function setBaseDef(baseDef:int):void{ _baseDef = baseDef; }
		public function setBaseAttMag(baseAttMag:int):void{ _baseAttMag = baseAttMag; }
		public function setBaseDefMag(baseDefMag:int):void{ _baseDefMag = baseDefMag; }
						
	} //class
} //package