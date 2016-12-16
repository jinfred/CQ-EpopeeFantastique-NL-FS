package  {
	import flash.display.MovieClip;
	
	public class Collision extends MovieClip {
		public function Collision() {
			// CONSTRUCTEUR
			if(parent is Obstacle) { 
				MovieClip(parent).definirZoneCollision(this);
			} else {
				//Si ce n'est pas un obstacle, c'est probablement parce que le parent est utilisé en mode symbole graphique.
				//Pour éviter des erreurs, le traitement est donc différent!
				visible=false; //on masque la zone de collision
				
				log(this+" est une boite qui ne sera pas considérée dans un obstacle...",4);
			} //if+else
		} //function
	} //class
} //package