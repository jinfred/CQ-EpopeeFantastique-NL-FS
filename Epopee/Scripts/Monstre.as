package  {
	
	public class Monstre extends Etre {
		private var _valeurXP:Number; // sa valeur en points d'expérience
		private var _estMort:Boolean = false; // son état mort (true) ou vivant (false)

		public function Monstre(){ } // CONSTRUCTEUR
				
		/******************************************************************************
		Fonction initParam
		******************************************************************************/		
		public function initParam(nom:String, PVAct:int, PVMax:int, PMAct:int, PMMax:int, baseAtt:int, baseDef:int, baseAttMag:int, baseDefMag:int, baseVitesse:int, valeurXP:Number) {
			initParamEtre(nom, PVAct, PVMax, PMAct, PMMax, baseAtt, baseDef, baseAttMag, baseDefMag, baseVitesse, "Monstre"); //transmission des paramètres au constructeur de l'Etre
			_valeurXP = valeurXP;
		} //initParam
			
		/******************************************************************************
		*******************************     GETTERS     *******************************
		******************************************************************************/
		public function getValeurXP():Number { log("XP +"+_valeurXP, 3); return _valeurXP; }
		public function getEstMort():Boolean { return _estMort; }
			
		/******************************************************************************
		*******************************     SETTERS     *******************************
		******************************************************************************/
		public function setEstMort(estMort:Boolean):void { _estMort = estMort; }
		
	} //class
} //package