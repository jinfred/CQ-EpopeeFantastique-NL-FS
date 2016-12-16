package  {

	/******************************************************************************
	Fonction log
	
	  C'est une fonction globale (accessible de partout).
	
	  Elle permet d'afficher un message à la manière d'une trace, 
	  mais on peut définir le niveau de priorité de chaque message.
	
	  Le niveau minimal que l'on souhaite afficher peut être modifié facilement,
	  ce qui permet de réduire ou augmenter le nombre de messages affichés.
	
	  // Légende des niveaux:
		• 1 = un bogue à réparer
		• 2 = une information qui aide à comprendre le déroulement
		• 3 = une information banale
		• 4 = une information anecdotique et répétitive
		• 5 = ?!
	******************************************************************************/

	public function log(quoi, priorite:uint=1):void {

		var prioriteMin:uint = 2; //valeur à modifier pour augmenter ou réduire le nombre de messages affichés
		
		var montrerLesErreursP1:Boolean = true; //doit-on montrer les BOGUES (niveau de priorité 1)?
		if(priorite<=prioriteMin){
			if(priorite==1 && montrerLesErreursP1){ throw new Error(quoi); } //ATTENTION! Le message sera affiché directement à l'utilisateur (si priorité 1 et montrerLesErreursP1)
			if(priorite==1){ quoi="***** "+quoi+" *****"; } //ajout de caractères pour faire ressortir le contenu dans la boîte de sortie...
			//le message doit être affiché, car sa priorité est suffisante:
			trace(quoi);		
		} else {
			//le message ne sera pas affiché, car sa priorité est insuffisante
		} //if+else
		
	} //fonction log
	
} //package
