# Take@Shoot - Cadrage MVP Public

Date : 2026-06-06  
Statut : socle produit et architecture valide  
Portee : MVP mobile pour lancement public controle, dimensionne pour plusieurs milliers d'utilisateurs

## 1. Positionnement Produit

Take@Shoot est un reseau social mobile de souvenirs instantanes. L'app reprend l'idee de spontaneite de BeReal, mais l'objet central n'est pas une simple photo : c'est un souvenir photobooth digital.

Promesse produit :

> Les souvenirs disparaissent du feed, pas de ta memoire.

Take@Shoot n'est pas :

- un reseau de createurs ;
- un reseau de performance ;
- un reseau de decouverte publique ;
- une app de selfies uniquement.

Take@Shoot est un reseau social ferme ou des potes capturent des moments reels et les transforment en souvenirs esthetiques.

## 2. Perimetre MVP Produit

Le MVP cible iOS et Android avec une direction artistique sombre, premium, centree sur la carte photobooth Take@Shoot.

Inclus dans le MVP :

- Authentification email et mot de passe.
- Profil public obligatoire avec `@pseudo` unique.
- MugShoot obligatoire pendant l'onboarding.
- Ajout de potes par demande et acceptation.
- Feed des potes uniquement.
- Feed chronologique.
- Capture live d'un Shoot en 4 photos.
- Camera avant ou arriere pour MugShoot et Shoot.
- Aucun import galerie pour MugShoot ou Shoot.
- Un template photobooth officiel au lancement.
- Filtres Vintage et Noir & Blanc au lancement.
- Modele extensible pour ajouter templates et filtres plus tard.
- Preview locale mobile et rendu officiel backend.
- Reactions avec une seule reaction active par utilisateur et par Shoot.
- Commentaires avec un niveau de reponses.
- Tags de potes.
- Souvenirs prives pour les Shoots crees par l'utilisateur.
- Section privee `Identifie(e)` pour les Shoots ou l'utilisateur est tague.
- Localisation ville/pays.
- Lieu ou etablissement optionnel, proche du comportement Instagram.
- Telechargement par le proprietaire et les potes tagues.
- Francais, anglais, espagnol.
- Notifications sociales.
- Maximum une notification de rappel produit par jour.
- Back-office admin de base.
- Blocage, signalement, moderation et alertes automatiques non bloquantes.

Exclus du MVP :

- Feed public.
- Classement algorithmique.
- Publicites.
- Suggestions d'amis.
- Import de contacts.
- Recherche par numero de telephone.
- Messages prives.
- Stories.
- Groupes.
- Videos.
- IA creative.
- Carte interactive.
- Pages publiques de lieux.
- Calendrier public avance.
- Recap mensuel.
- Templates et filtres supplementaires au-dela du set de lancement.

## 3. Authentification Et Identite

L'identite d'authentification et l'identite publique sont separees.

Authentification :

- L'utilisateur s'inscrit et se connecte avec email et mot de passe.
- L'email doit etre verifie avant publication.
- Le `@pseudo` n'est jamais utilise pour se connecter.
- Apple et Google OAuth doivent pouvoir etre ajoutes plus tard sans casser les comptes existants.

Identite publique :

- Le `@pseudo` est obligatoire pour finaliser le profil.
- Le `@pseudo` est unique.
- Le `@pseudo` sert a la recherche, aux tags, au profil et aux futures mentions.
- La creation du profil demande aussi le prenom et la photo de profil.
- Le pays est obligatoire.
- La ville et la bio sont optionnelles.

## 4. Onboarding Et MugShoot

Le MugShoot est obligatoire pendant l'onboarding. Ce n'est pas seulement une contrainte de profil : c'est le premier contact avec la direction artistique et le geste Take@Shoot.

Parcours :

1. L'utilisateur cree son compte.
2. L'utilisateur complete son profil minimal.
3. L'app lance la capture du MugShoot.
4. L'utilisateur prend 4 photos live en rafale.
5. L'utilisateur peut refaire sans limite avant validation.
6. L'utilisateur valide son MugShoot.
7. L'utilisateur entre dans l'app.

Regles MugShoot :

- 4 photos live.
- Camera avant ou arriere.
- Aucun import galerie.
- Retake illimite avant validation.
- Visible sur le profil par les potes acceptes.
- Modifiable plus tard par le proprietaire.
- Un nouveau MugShoot remplace l'ancien.

## 5. Modele Social Et Visibilite

Le MVP Take@Shoot est un reseau ferme entre potes acceptes.

Relation d'amitie :

- Recherche uniquement par `@pseudo`.
- Pas de recherche par telephone.
- Pas d'import contacts.
- Pas de suggestions d'amis.
- Une demande de pote peut etre envoyee et annulee.
- Le destinataire peut accepter ou refuser.
- Le refus est silencieux.
- Une amitie acceptee est reciproque.

Avant acceptation, un profil recherche expose uniquement :

- photo de profil ;
- prenom ;
- `@pseudo`.

Avant acceptation, le profil n'expose pas :

- bio ;
- ville ou pays ;
- MugShoot ;
- Shoots ;
- archives.

Profil visible par les potes acceptes :

- photo de profil ;
- prenom et `@pseudo` ;
- bio ;
- nombre de potes ;
- nombre de Shoots ;
- MugShoot.

Le profil visible par les potes n'expose pas :

- anciens Shoots apres 24h ;
- archives ;
- souvenirs prives ;
- Shoots ou l'utilisateur est tague.

Profil vu par soi-meme :

- toutes les informations publiques ;
- acces prive aux archives ;
- section `Mes Shoots` pour les Shoots crees par l'utilisateur ;
- section `Identifie(e)` pour les Shoots ou l'utilisateur est tague.

Visibilite d'un Shoot :

- visible dans le feed des potes pendant 24h ;
- disparait ensuite du feed et des surfaces sociales ;
- reste dans les souvenirs prives du proprietaire ;
- reste dans la section privee `Identifie(e)` d'un utilisateur tague tant que le tag existe et que le proprietaire conserve le Shoot ;
- ne devient jamais public dans le MVP.

Evolutions sociales hors MVP :

- filtre `Proches` parmi les potes acceptes ;
- visibilite potes de potes ;
- suggestions d'amis ;
- surfaces publiques ou semi-publiques de lieux/evenements ;
- archives ou collections partagees.

## 6. Capture, Rendu Et Media

Un Shoot est l'objet principal de publication.

Regles Shoot :

- 4 photos live en rafale.
- Intervalle cible autour de 1 a 1,5 seconde.
- Camera avant ou arriere.
- Aucun import galerie.
- Un template photobooth officiel au lancement.
- Filtre Vintage ou Noir & Blanc au lancement.
- Titre optionnel.
- Tags de potes optionnels.
- Localisation ville/pays.
- Lieu ou etablissement optionnel.
- Publication dans le feed des potes pendant 24h.
- Archivage automatique prive chez le proprietaire.

Stockage media :

- Stocker les 4 photos originales.
- Stocker le rendu photobooth final officiel.
- Stocker les assets optimises feed/thumbnail si necessaire.
- Les originaux ne sont pas exposes comme fichiers publics.
- Les originaux servent aux exports haute qualite et a une regeneration future.

Rendu :

- L'app mobile genere une preview locale rapide.
- Le backend genere le rendu officiel canonique.
- Le feed utilise le rendu officiel des qu'il est pret.
- Le modele doit permettre d'ajouter templates et filtres sans refonte de schema.

Consultation d'un Shoot :

- Premier element du carrousel : rendu photobooth final.
- Elements suivants : les 4 photos sources.
- L'acces aux photos sources suit les memes regles de visibilite que le Shoot.

## 7. Templates Et Filtres

Set de lancement :

- un template photobooth officiel Take@Shoot ;
- filtre Vintage ;
- filtre Noir & Blanc.

L'implementation doit traiter templates et filtres comme des concepts versionnes. Un Shoot publie garde l'identite de template/filtre choisie, afin que les futurs ajouts ne modifient pas les souvenirs existants de maniere inattendue.

Ajouts futurs :

- templates supplementaires ;
- filtres supplementaires ;
- variantes saisonnieres ou evenementielles ;
- templates premium ou limites, hors MVP.

## 8. Tags, Telechargement Et Propriete

Propriete :

- Le createur reste proprietaire du Shoot.
- Les utilisateurs tagues ne deviennent pas proprietaires.

Tags :

- Seuls les potes acceptes peuvent etre tagues.
- Un utilisateur tague peut retirer son propre tag.
- Retirer son tag retire l'acces a l'archive taguee et au droit de telechargement lie au tag.

Telechargement :

- Le proprietaire peut telecharger ses Shoots.
- Les potes tagues peuvent telecharger tant que le tag existe.
- Les autres potes peuvent voir mais ne peuvent pas telecharger par defaut.

Exports :

- version publiee ;
- version Vintage ;
- version Noir & Blanc ;
- les deux versions.

## 9. Localisation Et Lieux

Localisation MVP :

- Afficher ville et pays.
- Ne pas exposer les coordonnees GPS precises aux autres utilisateurs.
- Utiliser la position du telephone pour proposer ville/pays et lieux proches si la permission est donnee.

Lieu MVP :

- Champ lieu/etablissement optionnel.
- L'utilisateur peut chercher parmi des lieux proches suggeres.
- L'utilisateur peut saisir librement un nom si le lieu n'existe pas.
- L'affichage peut etre `Lieu - Ville, Pays` ou seulement `Ville, Pays`.
- Pas de page publique de lieu dans le MVP.
- Pas de carte interactive dans le MVP.

Le modele de donnees doit permettre plus tard d'ajouter un `place_id` fournisseur, des categories, des pages lieux, des pages evenements et une carte.

## 10. Reactions Et Commentaires

Reactions :

- Un utilisateur peut avoir une seule reaction active par Shoot.
- Changer de reaction remplace la reaction precedente.
- Les compteurs refletent uniquement les reactions actives.

Commentaires :

- Un Shoot peut avoir des commentaires.
- Un commentaire peut avoir des reponses.
- Les reponses ont une profondeur maximale de 1.
- Repondre a une reponse rattache la nouvelle reponse au commentaire principal, avec mention si necessaire.
- Commentaires et reponses sont signalables et moderables.

## 11. Notifications

Categories :

- demande de pote ;
- demande acceptee ;
- commentaire ;
- reponse ;
- reaction ;
- tag ;
- rappel produit.

Regles :

- Les rappels produit sont limites a un maximum d'un par jour.
- Les notifications sociales sont autorisees en dehors de cette limite.
- L'utilisateur peut gerer les categories de notifications.
- Le serveur applique un rate limiting pour eviter le spam.

## 12. Suppression Et Retention

Modele par defaut :

- Le soft delete masque immediatement le contenu dans l'app.
- La purge reelle intervient apres un delai planifie.
- Delai propose par defaut : 30 jours.

Suppression d'un Shoot :

- Masque immediatement.
- Retire du feed, des souvenirs du proprietaire et des archives taguees.
- Fichiers et lignes purges apres le delai de retention.

Suppression de compte :

- Compte desactive immediatement.
- Profil et contenus masques selon le flux de suppression.
- Donnees et fichiers purges apres le delai de retention.

Exception moderation/juridique :

- Des preuves minimales peuvent etre conservees si necessaire pour abus, obligations legales ou securite plateforme.
- Ce point doit etre documente dans la politique de confidentialite et les procedures admin.

## 13. Moderation, Securite Et Admin

Moderation MVP :

- bloquer un utilisateur ;
- retirer un pote ;
- signaler un Shoot ;
- signaler un commentaire ;
- signaler un profil ;
- supprimer un contenu cote admin ;
- suspendre un compte cote admin ;
- restaurer pendant la fenetre de soft delete ;
- journaliser les actions sensibles.

Detection automatique :

- Non bloquante par defaut.
- Detection de texte suspect, spam, volume d'actions anormal, signalements repetes, et eventuellement risque image leger.
- Creation d'alertes dans le back-office.
- Pas de blocage automatique de publication sauf regle critique future explicitement validee.

Back-office :

- Application web Next.js.
- Acces admin protege.
- Roles admin stricts.
- Aucune cle service exposee au navigateur.
- Actions sensibles via endpoints serveur.

Ecrans admin MVP :

- liste utilisateurs et recherche par email, pseudo ou ID interne ;
- detail utilisateur ;
- file des signalements ;
- file des alertes automatiques ;
- Shoots/commentaires/profils signales ;
- suppression/restauration de contenu ;
- suspension/reactivation de compte ;
- logs d'actions sensibles ;
- support basique.

## 14. Architecture Technique

Stack recommandee :

- Mobile : React Native, Expo, TypeScript.
- Navigation : Expo Router.
- Build/distribution : EAS Build et EAS Submit.
- Admin : Next.js, TypeScript.
- Backend : Supabase.
- Base de donnees : Postgres.
- Auth : Supabase Auth.
- Autorisation : Row Level Security Postgres.
- Media : Supabase Storage avec acces prive/authentifie.
- Fonctions backend : Supabase Edge Functions ou petit serveur dedie pour operations privilegiees.
- Realtime : uniquement la ou utile, par exemple feed, commentaires, notifications ou statut de traitement.

Decision repository :

- Take@Shoot part en monorepo des le debut.
- L'app mobile, l'admin, les types partages, schemas de validation, constantes, tokens de design et assets Supabase doivent evoluer ensemble.
- Le monorepo garde une seule source de verite pour les contrats produit et evite les divergences entre mobile, admin et backend.

Structure cible :

```text
apps/
  mobile/
  admin/
packages/
  shared/
  ui/
supabase/
  migrations/
  functions/
  seed/
docs/
  superpowers/
    specs/
```

Code partage :

- types ;
- schemas de validation ;
- constantes ;
- identifiants reactions/filtres/templates ;
- cles de traduction si pertinent.

Qualite et operations :

- Sentry mobile et admin.
- Logs backend structures.
- Analytics produit sobres, avec donnees personnelles limitees.
- Monitoring du pipeline media.
- Migrations SQL versionnees.
- Tests des policies RLS.
- CI GitHub.
- Environnements separes dev, staging et production.

## 15. Concepts De Donnees

Entites probables :

- `auth.users` gere par Supabase Auth ;
- `profiles` ;
- `friend_requests` ;
- `friendships` ;
- `mugshoots` ;
- `shoots` ;
- `shoot_media` ;
- `shoot_tags` ;
- `shoot_reactions` ;
- `shoot_comments` ;
- `places` ;
- `notifications` ;
- `reports` ;
- `moderation_alerts` ;
- `admin_actions` ;
- `blocks` ;
- `notification_preferences`.

Contraintes importantes :

- Les policies RLS doivent appliquer visibilite amis, propriete, acces tague et archives privees.
- Les checks cote client ne suffisent pas pour la confidentialite.
- L'acces aux objets media doit suivre le meme modele d'autorisation que les lignes de base de donnees.
- Les Shoots publies doivent referencer les versions de template/filtre.
- L'etat de soft delete doit etre respecte partout.

## 16. Roadmap Apres MVP

Candidats V1.x :

- connexion Apple et Google ;
- liste/filtre `Proches` ;
- templates et filtres supplementaires ;
- meilleure integration fournisseur de lieux ;
- pages lieux ou evenements ;
- visibilite potes de potes ;
- moderation automatique plus avancee ;
- calendrier souvenirs ;
- recap mensuel ;
- collections de souvenirs partagees ;
- raffinement des notifications push.

Explicitement plus tard, pas MVP :

- messages prives ;
- stories ;
- groupes ;
- videos ;
- decouverte publique ;
- publicites ;
- experience carte complete.

## 17. Decisions A Reprendre Plus Tard

Ces decisions ne sont pas necessaires pour demarrer l'implementation MVP :

- delai exact de retention si 30 jours change apres revue juridique/confidentialite ;
- fournisseur exact de lieux ;
- fournisseur exact de moderation image ;
- fournisseur exact d'analytics ;
- details exacts du moteur de rendu backend ;
- wording exact de l'onboarding et des notifications ;
- regles de regeneration des anciens templates si le design evolue.

Ces decisions ne doivent pas rouvrir le perimetre MVP valide sans validation explicite.
