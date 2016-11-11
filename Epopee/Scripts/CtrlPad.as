package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class CtrlPad extends MovieClip {
		private var _actif:Boolean;
		private var _dir:uint;
		private const FIXE:uint=1, HAUT:uint=2, DROITE:uint=4, BAS:uint=6, GAUCHE:uint=8;
		private const HAUT_DROITE:uint=3, BAS_DROITE:uint=5, BAS_GAUCHE:uint=7, HAUT_GAUCHE:uint=9;
		
		private var _jeu:MovieClip;
		
		public function CtrlPad() {
			// CONSTRUCTEUR
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/******************************************************************************
		Fonction init
		******************************************************************************/		
		private function init(e:Event):void{
			stop();
			
			// initialisation des références du parent:
			_jeu = MovieClip(parent); // initialisation des références du parent			
			
			addEventListener(MouseEvent.MOUSE_DOWN, enfoncerBtn);
			addEventListener(MouseEvent.MOUSE_UP, relacherBtn);
			addEventListener(MouseEvent.ROLL_OUT, relacherBtn);
			addEventListener(MouseEvent.ROLL_OVER, enfoncerBtn);
			addEventListener(Event.REMOVED_FROM_STAGE, menage);
		}
		
		/******************************************************************************
		Fonction enfoncerBtn
		******************************************************************************/		
		private function enfoncerBtn(e:MouseEvent):void{
			if(e.type == MouseEvent.MOUSE_DOWN || e.buttonDown){
				_actif = true;
				addEventListener(Event.ENTER_FRAME, loop);
			}
		}
		
		/******************************************************************************
		Fonction relacherBtn
		******************************************************************************/		
		private function relacherBtn(e:MouseEvent):void{
			if(e.type == MouseEvent.MOUSE_UP || e.buttonDown){
				_actif = false;
				removeEventListener(Event.ENTER_FRAME, loop);
				loop(); //un appel de plus pour réinitialisé les flèches
			}			
		}		
		
		/******************************************************************************
		Fonction menage
		******************************************************************************/		
		private function menage(e:Event):void{
			_dir=FIXE;
			gotoAndStop(FIXE);
			_actif = false;
			removeEventListener(Event.ENTER_FRAME, loop);
		}
		
		/******************************************************************************
		Fonction loop
		******************************************************************************/		
		private function loop(e:Event=null):void{
			var angle:Number = Math.atan2(mouseY,mouseX)*180/Math.PI;
			log(angle,3);
						
			if(angle>-112.5 && angle<-67.5 && _actif){
				if(_dir!=HAUT){
					_dir=HAUT;
					gotoAndStop(HAUT);
					_jeu.bougerPad(false,false,true,false);//(gauche,droite,haut,bas)
				} //if
			} else if(angle>=-67.5 && angle<=-22.5 && _actif){
				if(_dir!=HAUT_DROITE){
					_dir=HAUT_DROITE;
					gotoAndStop(HAUT_DROITE);
					_jeu.bougerPad(false,true,true,false);//(gauche,droite,haut,bas)
				} //if
			} else if(angle>=-22.5 && angle<=22.5 && _actif){
				if(_dir!=DROITE){
					_dir=DROITE;
					gotoAndStop(DROITE);
					_jeu.bougerPad(false,true,false,false);//(gauche,droite,haut,bas)
				} //if
			} else if(angle>=22.5 && angle<=67.5 && _actif){
				if(_dir!=BAS_DROITE){
					_dir=BAS_DROITE;
					gotoAndStop(BAS_DROITE);
					_jeu.bougerPad(false,true,false,true);//(gauche,droite,haut,bas)
				} //if
			} else if(angle>67.5 && angle<112.5 && _actif){
				if(_dir!=BAS){
					_dir=BAS;
					gotoAndStop(BAS);
					_jeu.bougerPad(false,false,false,true);//(gauche,droite,haut,bas)
				} //if		
			} else if(angle>112.5 && angle<157.5 && _actif){
				if(_dir!=BAS_GAUCHE){
					_dir=BAS_GAUCHE;
					gotoAndStop(BAS_GAUCHE);
					_jeu.bougerPad(true,false,false,true);//(gauche,droite,haut,bas)
				} //if			
			}else if((angle>=157.5 || angle<=-157.5) && _actif){
				if(_dir!=GAUCHE){
					_dir=GAUCHE;
					gotoAndStop(GAUCHE);
					_jeu.bougerPad(true,false,false,false);//(gauche,droite,haut,bas)
				} //if
			}else if((angle>=-157.5 && angle<-112.5) && _actif){
				if(_dir!=HAUT_GAUCHE){
					_dir=HAUT_GAUCHE;
					gotoAndStop(HAUT_GAUCHE);
					_jeu.bougerPad(true,false,true,false);//(gauche,droite,haut,bas)
				} //if
			}  else {
				if(_dir!=FIXE){
					_dir=FIXE;
					gotoAndStop(FIXE);
					_jeu.bougerPad(false,false,false,false);//(gauche,droite,haut,bas)
				} //if
			} //if+else if+else
			log(_dir, 3);
		} //function
		
	} //class
} //package