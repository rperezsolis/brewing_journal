// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Cata Café';

  @override
  String get myRecipes => 'Mis recetas';

  @override
  String get teams => 'Equipos';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get newRecipe => 'Nueva receta';

  @override
  String get retry => 'Reintentar';

  @override
  String get noRecipesYet => 'Aún no hay recetas';

  @override
  String get noRecipesYetDetail =>
      'Toca Nueva receta para registrar tu primera preparación.';

  @override
  String recipeByline(String author, String updated) {
    return '$author · $updated';
  }

  @override
  String get unknownAuthor => 'Autor desconocido';

  @override
  String get pageNotFound => 'Esta página no existe.';

  @override
  String get goHome => 'Ir al inicio';

  @override
  String get connectionError =>
      'No se puede conectar con el servidor. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get genericError => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get recipeNotFound => 'Receta no encontrada';

  @override
  String get cantEditRecipe => 'No puedes editar esta receta';

  @override
  String get photoNotVerified =>
      'No se pudo verificar la foto. Inténtalo de nuevo u omítela.';

  @override
  String get inviteExpired =>
      'Esta invitación venció. Pídele una nueva a quien administra el equipo.';

  @override
  String get inviteUsed => 'Esta invitación ya se usó.';

  @override
  String get alreadyMember => 'Ya estás en este equipo.';

  @override
  String get recipeNotFoundOrUnshared =>
      'Receta no encontrada o ya no está compartida contigo';

  @override
  String get viewersCantChange =>
      'Los lectores no pueden cambiar las recetas del equipo.';

  @override
  String get recipeCouldNotBeLoaded => 'No se pudo cargar esta receta.';

  @override
  String get photoFormatUnsupported =>
      'Este formato de imagen no es compatible. Elige un JPEG o PNG.';

  @override
  String get coffee => 'Café';

  @override
  String get tea => 'Té';

  @override
  String get matcha => 'Matcha';

  @override
  String get roastLight => 'Claro';

  @override
  String get roastMedium => 'Medio';

  @override
  String get roastMediumDark => 'Medio oscuro';

  @override
  String get roastDark => 'Oscuro';

  @override
  String get methodV60 => 'V60';

  @override
  String get methodEspresso => 'Espresso';

  @override
  String get methodFrenchPress => 'Prensa francesa';

  @override
  String get methodAeropress => 'AeroPress';

  @override
  String get methodChemex => 'Chemex';

  @override
  String get methodColdBrew => 'Cold brew';

  @override
  String get methodMatchaWhisk => 'Batidor de matcha';

  @override
  String get methodOther => 'Otro';

  @override
  String get roleViewer => 'Lector';

  @override
  String get roleEditor => 'Editor';

  @override
  String get stepBean => 'Grano';

  @override
  String get stepBrew => 'Preparación';

  @override
  String get stepFlavor => 'Sabor';

  @override
  String get stepSteps => 'Pasos';

  @override
  String get stepPhotos => 'Fotos';

  @override
  String get editRecipe => 'Editar receta';

  @override
  String get close => 'Cerrar';

  @override
  String get back => 'Atrás';

  @override
  String get finish => 'Terminar';

  @override
  String get next => 'Siguiente';

  @override
  String get whatAreYouBrewing => '¿Qué vas a preparar?';

  @override
  String searchIngredient(String kind) {
    return 'Busca tu $kind';
  }

  @override
  String get nothingRegistered => 'Todavía no hay nada registrado.';

  @override
  String noMatches(String query) {
    return 'No hay coincidencias para \"$query\".';
  }

  @override
  String registerNewKind(String kind) {
    return 'Registrar nuevo $kind';
  }

  @override
  String get nameLabel => 'Nombre';

  @override
  String get originOptional => 'Origen (opcional)';

  @override
  String get roasterOptional => 'Tostador o productor (opcional)';

  @override
  String get roastLevelOptional => 'Nivel de tueste (opcional)';

  @override
  String get notSet => 'Sin definir';

  @override
  String get processingOptional => 'Proceso (opcional)';

  @override
  String get processingHint => 'Lavado, natural, bajo sombra…';

  @override
  String get register => 'Registrar';

  @override
  String get brewParameters => 'Parámetros de preparación';

  @override
  String get recipeTitle => 'Título de la receta';

  @override
  String get waterTemperature => 'Temperatura del agua';

  @override
  String get dose => 'Dosis';

  @override
  String get waterQuantity => 'Cantidad de agua';

  @override
  String get grindSize => 'Tamaño de molienda';

  @override
  String get grindSizeHint => 'Media-fina, 18 clics…';

  @override
  String get grinderModel => 'Modelo del molino';

  @override
  String get grinderModelHint => 'Comandante C40, Niche Zero…';

  @override
  String get extractionMethodLabel => 'Método de extracción';

  @override
  String get describeTheMethod => 'Describe el método';

  @override
  String get enterTime => 'O escribe el tiempo (m:ss)';

  @override
  String get timeFormatError => 'Usa m:ss, por ejemplo 2:30';

  @override
  String get extractionTime => 'Tiempo de extracción';

  @override
  String get stop => 'Detener';

  @override
  String get start => 'Iniciar';

  @override
  String get reset => 'Reiniciar';

  @override
  String get flavorMap => 'Mapa de sabor';

  @override
  String get flavorTags => 'Etiquetas de sabor';

  @override
  String get addTagHint => 'Agrega una etiqueta (frutal, chocolate, floral…)';

  @override
  String atMostTags(int count) {
    return 'Máximo $count etiquetas';
  }

  @override
  String get addTag => 'Agregar etiqueta';

  @override
  String get acidity => 'Acidez';

  @override
  String get sweetness => 'Dulzor';

  @override
  String get flavorBody => 'Cuerpo';

  @override
  String get bitterness => 'Amargor';

  @override
  String flavorMapSemantics(
    int acidity,
    int sweetness,
    int body,
    int bitterness,
    int maxScore,
  ) {
    return 'Mapa de sabor: acidez $acidity, dulzor $sweetness, cuerpo $body, amargor $bitterness, de $maxScore';
  }

  @override
  String get extraSteps => 'Pasos extra';

  @override
  String get skip => 'Omitir';

  @override
  String get extraStepsHelp =>
      'Opcional. Cualquier cosa fuera de los parámetros, como \"usar 150 ml de leche entera\" o \"agregar canela y revolver\".';

  @override
  String atMostSteps(int count) {
    return 'Máximo $count pasos';
  }

  @override
  String get addAStep => 'Agrega un paso';

  @override
  String get addStep => 'Agregar paso';

  @override
  String get noExtraSteps => 'Aún no hay pasos extra.';

  @override
  String get reorder => 'Reordenar';

  @override
  String get editStep => 'Editar paso';

  @override
  String get removeStep => 'Quitar paso';

  @override
  String get stepCantBeEmpty => 'Un paso no puede estar vacío';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get photos => 'Fotos';

  @override
  String photosHelp(int count) {
    return 'Opcional. Agrega hasta $count fotos de la taza, la crema o el empaque, o toca Terminar para guardar sin fotos.';
  }

  @override
  String get removePhoto => 'Quitar foto';

  @override
  String get addPhoto => 'Agregar foto';

  @override
  String get processingImages => 'Procesando imágenes';

  @override
  String get deleteRecipeTitle => '¿Eliminar esta receta?';

  @override
  String deleteRecipeBody(String title) {
    return 'Se eliminará “$title”. Esta acción no se puede deshacer.';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get createOrJoinTeam =>
      'Primero crea un equipo o únete a uno como editor.';

  @override
  String get addToTeam => 'Agregar al equipo';

  @override
  String get brewFallback => 'Preparación';

  @override
  String get share => 'Compartir';

  @override
  String get removeFromTeam => 'Quitar del equipo';

  @override
  String get edit => 'Editar';

  @override
  String get prepAndExtraSteps => 'Preparación y pasos extra';

  @override
  String get noExtractionTime => 'No hay tiempo de extracción registrado';

  @override
  String get extractionTimer => 'Temporizador de extracción';

  @override
  String targetDuration(String time) {
    return 'Objetivo $time';
  }

  @override
  String get countDown => 'Cuenta regresiva';

  @override
  String get countUp => 'Cuenta ascendente';

  @override
  String get stopAlarm => 'Detener alarma';

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Reanudar';

  @override
  String get couldNotCreateShareImage =>
      'No se pudo crear la imagen para compartir.';

  @override
  String get couldNotSaveImage => 'No se pudo guardar la imagen.';

  @override
  String get sharingNotSupported =>
      'Compartir no está disponible aquí. Descarga la imagen.';

  @override
  String get downloadImage => 'Descargar imagen';

  @override
  String get madeWithBrewSync => 'Hecho con Cata Café';

  @override
  String brewingSummary(String method, String dose, String temp) {
    return 'Preparación: $method · $dose g · $temp °C';
  }

  @override
  String brewingSummaryWithWater(
    String method,
    String dose,
    String water,
    String temp,
  ) {
    return 'Preparación: $method · $dose g · $water ml · $temp °C';
  }

  @override
  String grindingSummary(String grind, String grinder) {
    return 'Molienda: $grind · $grinder';
  }

  @override
  String kindAndName(String kind, String name) {
    return '$kind: $name';
  }

  @override
  String moreCount(int count) {
    return '+$count más';
  }

  @override
  String timerSummary(String minutes, String seconds) {
    return 'Temporizador: ${minutes}m ${seconds}s';
  }

  @override
  String get joinWithInvite => 'Unirse con invitación';

  @override
  String get createTeam => 'Crear equipo';

  @override
  String get noTeamsYet =>
      'Aún no hay equipos. Crea uno o únete con una invitación.';

  @override
  String ownerRole(String role) {
    return 'Dueño · $role';
  }

  @override
  String get create => 'Crear';

  @override
  String get inviteUrlOrToken => 'URL o token de invitación';

  @override
  String get join => 'Unirse';

  @override
  String get inviteToTeam => 'Invitar al equipo';

  @override
  String get inviteTtlOneHour => '1 h';

  @override
  String get inviteTtlOneDay => '24 h';

  @override
  String get inviteTtlOneWeek => '7 d';

  @override
  String get inviteLinkCopied => 'Enlace de invitación copiado';

  @override
  String inviteClipboardMessage(String team, String url) {
    return 'Te invito a unirte a $team en Cata Café. Allí compartimos recetas, notas de cata y las tazas que más nos gustan.\n\n$url';
  }

  @override
  String get copyLink => 'Copiar';

  @override
  String get singleUse => 'Un solo uso';

  @override
  String get teamFallback => 'Equipo';

  @override
  String get invite => 'Invitar';

  @override
  String get noRecipesOnTeam => 'Aún no hay recetas en este equipo.';

  @override
  String get teamInvite => 'Invitación al equipo';

  @override
  String youJoined(String team, String role) {
    return 'Te uniste a $team como $role.';
  }

  @override
  String get inviteNotFound => 'Invitación no encontrada.';

  @override
  String get openTeam => 'Abrir equipo';

  @override
  String validationNameLength(int max) {
    return 'El nombre debe tener entre 1 y $max caracteres';
  }

  @override
  String validationTagTooLong(int max) {
    return 'Una etiqueta debe tener como máximo $max caracteres';
  }

  @override
  String validationTooManyTags(int max) {
    return 'Máximo $max etiquetas';
  }

  @override
  String validationTooManyInstructions(int max) {
    return 'Máximo $max instrucciones';
  }

  @override
  String get validationEmptyInstruction =>
      'Una instrucción no puede estar vacía';

  @override
  String validationInstructionTooLong(int max) {
    return 'Una instrucción debe tener como máximo $max caracteres';
  }

  @override
  String get validationSelectIngredient =>
      'Selecciona o registra un ingrediente';

  @override
  String get validationAddTitle => 'Agrega un título';

  @override
  String validationWaterTemp(int min, int max) {
    return 'La temperatura del agua debe estar entre $min y $max °C';
  }

  @override
  String validationDose(String min, String max) {
    return 'La dosis debe estar entre $min y $max g';
  }

  @override
  String validationWaterQuantity(String min, String max) {
    return 'La cantidad de agua debe estar entre $min y $max ml';
  }

  @override
  String get validationAddGrindSize => 'Agrega un tamaño de molienda';

  @override
  String get validationAddGrinder => 'Agrega un modelo de molino';

  @override
  String get validationChooseMethod => 'Elige un método de extracción';

  @override
  String get validationDescribeMethod => 'Describe el método de extracción';

  @override
  String get validationExtractionTime =>
      'El tiempo de extracción debe estar entre 1 s y 2 h';

  @override
  String validationTooManyPhotos(int max) {
    return 'Máximo $max fotos';
  }

  @override
  String get accept => 'Aceptar';

  @override
  String get addToFavorites => 'Agregar a favoritos';

  @override
  String get removeFromFavorites => 'Quitar de favoritos';

  @override
  String get showFavorites => 'Mostrar favoritos';

  @override
  String get showAllRecipes => 'Mostrar todas las recetas';

  @override
  String get favoriteNameTakenTitle => 'Ya está en favoritos';

  @override
  String get favoriteNameTakenBody =>
      'Ya hay una receta con ese nombre en tus favoritos. ¿Quieres reemplazarla por esta?';

  @override
  String get noFavoriteRecipes => 'No hay recetas favoritas';

  @override
  String get noFavoriteRecipesDetail =>
      'Guarda una receta para conservar la versión que quieres preparar.';

  @override
  String get showTeamFavorites => 'Mostrar favoritos del equipo';

  @override
  String get showAllTeamRecipes => 'Mostrar todas las recetas del equipo';

  @override
  String get favoriteNameTakenTitleTeam =>
      'Ya está en los favoritos del equipo';

  @override
  String get favoriteNameTakenBodyTeam =>
      'Ya hay una receta con ese nombre en los favoritos de este equipo. ¿Quieres reemplazarla por esta?';

  @override
  String get noTeamFavoriteRecipes => 'No hay favoritos del equipo';

  @override
  String get noTeamFavoriteRecipesDetail =>
      'Los editores guardan la versión que el equipo prepara.';

  @override
  String get viewersCantChangeTeamFavorites =>
      'Los lectores no pueden cambiar los favoritos del equipo.';

  @override
  String get authSignInWithEmail => 'Iniciar sesión con correo electrónico';

  @override
  String get authEmail => 'Correo electrónico';

  @override
  String get authPreferredName => 'Nombre preferido';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authForgotPassword => 'Olvidé mi contraseña';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get authSignIn => 'Iniciar sesión';

  @override
  String get authDontHaveAnAccount => '¿No tienes una cuenta?';

  @override
  String get authContinue => 'Continuar';

  @override
  String get authAlreadyHaveAnAccount => '¿Ya tienes una cuenta?';

  @override
  String get authVerifyAccountTitle => 'Verificar cuenta';

  @override
  String get authVerifyResetCodeTitle => 'Verificar código';

  @override
  String get authVerificationMessage =>
      'Enviamos un correo de verificación. Revisa tu bandeja de entrada e ingresa el código a continuación. Si no lo encuentras, revisa la carpeta de spam.';

  @override
  String get authVerify => 'Verificar';

  @override
  String get authSetAccountPasswordTitle => 'Establecer contraseña';

  @override
  String get authBackToSignUp => 'Volver al registro';

  @override
  String get authSetNewPasswordTitle => 'Establecer nueva contraseña';

  @override
  String get authNewPassword => 'Nueva contraseña';

  @override
  String get authResetPasswordTitle => 'Restablecer contraseña';

  @override
  String get authResetPasswordDescription =>
      'Ingresa el correo electrónico para restablecer la contraseña.';

  @override
  String get authRequestPasswordReset => 'Solicitar restablecimiento';

  @override
  String get authResetPassword => 'Restablecer contraseña';

  @override
  String get authBackToSignIn => 'Volver a iniciar sesión';

  @override
  String get authTermsIntro => 'He leído y acepto los ';

  @override
  String get authTermsAndConditions => 'Términos y condiciones';

  @override
  String get authAnd => ' y la ';

  @override
  String get authPrivacyPolicy => 'Política de privacidad';

  @override
  String get authNoProviders =>
      'No hay proveedores de autenticación configurados';

  @override
  String get authOrContinueWith => 'o continuar con';

  @override
  String authPasswordMinLength(String length) {
    return 'Al menos $length caracteres';
  }

  @override
  String authPasswordMaxLength(String length) {
    return 'Como máximo $length caracteres';
  }

  @override
  String get authPasswordLowercase => 'Contiene al menos una letra minúscula';

  @override
  String get authPasswordUppercase => 'Contiene al menos una letra mayúscula';

  @override
  String get authPasswordNumber => 'Contiene al menos un número';

  @override
  String get authPasswordSpecial => 'Contiene al menos un carácter especial';
}

/// The translations for Spanish Castilian, as used in Latin America and the Caribbean (`es_419`).
class AppLocalizationsEs419 extends AppLocalizationsEs {
  AppLocalizationsEs419() : super('es_419');

  @override
  String get appTitle => 'Cata Café';

  @override
  String get myRecipes => 'Mis recetas';

  @override
  String get teams => 'Equipos';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get newRecipe => 'Nueva receta';

  @override
  String get retry => 'Reintentar';

  @override
  String get noRecipesYet => 'Aún no hay recetas';

  @override
  String get noRecipesYetDetail =>
      'Toca Nueva receta para registrar tu primera preparación.';

  @override
  String recipeByline(String author, String updated) {
    return '$author · $updated';
  }

  @override
  String get unknownAuthor => 'Autor desconocido';

  @override
  String get pageNotFound => 'Esta página no existe.';

  @override
  String get goHome => 'Ir al inicio';

  @override
  String get connectionError =>
      'No se puede conectar con el servidor. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get genericError => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get recipeNotFound => 'Receta no encontrada';

  @override
  String get cantEditRecipe => 'No puedes editar esta receta';

  @override
  String get photoNotVerified =>
      'No se pudo verificar la foto. Inténtalo de nuevo u omítela.';

  @override
  String get inviteExpired =>
      'Esta invitación venció. Pídele una nueva a quien administra el equipo.';

  @override
  String get inviteUsed => 'Esta invitación ya se usó.';

  @override
  String get alreadyMember => 'Ya estás en este equipo.';

  @override
  String get recipeNotFoundOrUnshared =>
      'Receta no encontrada o ya no está compartida contigo';

  @override
  String get viewersCantChange =>
      'Los lectores no pueden cambiar las recetas del equipo.';

  @override
  String get recipeCouldNotBeLoaded => 'No se pudo cargar esta receta.';

  @override
  String get photoFormatUnsupported =>
      'Este formato de imagen no es compatible. Elige un JPEG o PNG.';

  @override
  String get coffee => 'Café';

  @override
  String get tea => 'Té';

  @override
  String get matcha => 'Matcha';

  @override
  String get roastLight => 'Claro';

  @override
  String get roastMedium => 'Medio';

  @override
  String get roastMediumDark => 'Medio oscuro';

  @override
  String get roastDark => 'Oscuro';

  @override
  String get methodV60 => 'V60';

  @override
  String get methodEspresso => 'Espresso';

  @override
  String get methodFrenchPress => 'Prensa francesa';

  @override
  String get methodAeropress => 'AeroPress';

  @override
  String get methodChemex => 'Chemex';

  @override
  String get methodColdBrew => 'Cold brew';

  @override
  String get methodMatchaWhisk => 'Batidor de matcha';

  @override
  String get methodOther => 'Otro';

  @override
  String get roleViewer => 'Lector';

  @override
  String get roleEditor => 'Editor';

  @override
  String get stepBean => 'Grano';

  @override
  String get stepBrew => 'Preparación';

  @override
  String get stepFlavor => 'Sabor';

  @override
  String get stepSteps => 'Pasos';

  @override
  String get stepPhotos => 'Fotos';

  @override
  String get editRecipe => 'Editar receta';

  @override
  String get close => 'Cerrar';

  @override
  String get back => 'Atrás';

  @override
  String get finish => 'Terminar';

  @override
  String get next => 'Siguiente';

  @override
  String get whatAreYouBrewing => '¿Qué vas a preparar?';

  @override
  String searchIngredient(String kind) {
    return 'Busca tu $kind';
  }

  @override
  String get nothingRegistered => 'Todavía no hay nada registrado.';

  @override
  String noMatches(String query) {
    return 'No hay coincidencias para \"$query\".';
  }

  @override
  String registerNewKind(String kind) {
    return 'Registrar nuevo $kind';
  }

  @override
  String get nameLabel => 'Nombre';

  @override
  String get originOptional => 'Origen (opcional)';

  @override
  String get roasterOptional => 'Tostador o productor (opcional)';

  @override
  String get roastLevelOptional => 'Nivel de tueste (opcional)';

  @override
  String get notSet => 'Sin definir';

  @override
  String get processingOptional => 'Proceso (opcional)';

  @override
  String get processingHint => 'Lavado, natural, bajo sombra…';

  @override
  String get register => 'Registrar';

  @override
  String get brewParameters => 'Parámetros de preparación';

  @override
  String get recipeTitle => 'Título de la receta';

  @override
  String get waterTemperature => 'Temperatura del agua';

  @override
  String get dose => 'Dosis';

  @override
  String get waterQuantity => 'Cantidad de agua';

  @override
  String get grindSize => 'Tamaño de molienda';

  @override
  String get grindSizeHint => 'Media-fina, 18 clics…';

  @override
  String get grinderModel => 'Modelo del molino';

  @override
  String get grinderModelHint => 'Comandante C40, Niche Zero…';

  @override
  String get extractionMethodLabel => 'Método de extracción';

  @override
  String get describeTheMethod => 'Describe el método';

  @override
  String get enterTime => 'O escribe el tiempo (m:ss)';

  @override
  String get timeFormatError => 'Usa m:ss, por ejemplo 2:30';

  @override
  String get extractionTime => 'Tiempo de extracción';

  @override
  String get stop => 'Detener';

  @override
  String get start => 'Iniciar';

  @override
  String get reset => 'Reiniciar';

  @override
  String get flavorMap => 'Mapa de sabor';

  @override
  String get flavorTags => 'Etiquetas de sabor';

  @override
  String get addTagHint => 'Agrega una etiqueta (frutal, chocolate, floral…)';

  @override
  String atMostTags(int count) {
    return 'Máximo $count etiquetas';
  }

  @override
  String get addTag => 'Agregar etiqueta';

  @override
  String get acidity => 'Acidez';

  @override
  String get sweetness => 'Dulzor';

  @override
  String get flavorBody => 'Cuerpo';

  @override
  String get bitterness => 'Amargor';

  @override
  String flavorMapSemantics(
    int acidity,
    int sweetness,
    int body,
    int bitterness,
    int maxScore,
  ) {
    return 'Mapa de sabor: acidez $acidity, dulzor $sweetness, cuerpo $body, amargor $bitterness, de $maxScore';
  }

  @override
  String get extraSteps => 'Pasos extra';

  @override
  String get skip => 'Omitir';

  @override
  String get extraStepsHelp =>
      'Opcional. Cualquier cosa fuera de los parámetros, como \"usar 150 ml de leche entera\" o \"agregar canela y revolver\".';

  @override
  String atMostSteps(int count) {
    return 'Máximo $count pasos';
  }

  @override
  String get addAStep => 'Agrega un paso';

  @override
  String get addStep => 'Agregar paso';

  @override
  String get noExtraSteps => 'Aún no hay pasos extra.';

  @override
  String get reorder => 'Reordenar';

  @override
  String get editStep => 'Editar paso';

  @override
  String get removeStep => 'Quitar paso';

  @override
  String get stepCantBeEmpty => 'Un paso no puede estar vacío';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get photos => 'Fotos';

  @override
  String photosHelp(int count) {
    return 'Opcional. Agrega hasta $count fotos de la taza, la crema o el empaque, o toca Terminar para guardar sin fotos.';
  }

  @override
  String get removePhoto => 'Quitar foto';

  @override
  String get addPhoto => 'Agregar foto';

  @override
  String get processingImages => 'Procesando imágenes';

  @override
  String get deleteRecipeTitle => '¿Eliminar esta receta?';

  @override
  String deleteRecipeBody(String title) {
    return 'Se eliminará “$title”. Esta acción no se puede deshacer.';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get createOrJoinTeam =>
      'Primero crea un equipo o únete a uno como editor.';

  @override
  String get addToTeam => 'Agregar al equipo';

  @override
  String get brewFallback => 'Preparación';

  @override
  String get share => 'Compartir';

  @override
  String get removeFromTeam => 'Quitar del equipo';

  @override
  String get edit => 'Editar';

  @override
  String get prepAndExtraSteps => 'Preparación y pasos extra';

  @override
  String get noExtractionTime => 'No hay tiempo de extracción registrado';

  @override
  String get extractionTimer => 'Temporizador de extracción';

  @override
  String targetDuration(String time) {
    return 'Objetivo $time';
  }

  @override
  String get countDown => 'Cuenta regresiva';

  @override
  String get countUp => 'Cuenta ascendente';

  @override
  String get stopAlarm => 'Detener alarma';

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Reanudar';

  @override
  String get couldNotCreateShareImage =>
      'No se pudo crear la imagen para compartir.';

  @override
  String get couldNotSaveImage => 'No se pudo guardar la imagen.';

  @override
  String get sharingNotSupported =>
      'Compartir no está disponible aquí. Descarga la imagen.';

  @override
  String get downloadImage => 'Descargar imagen';

  @override
  String get madeWithBrewSync => 'Hecho con Cata Café';

  @override
  String brewingSummary(String method, String dose, String temp) {
    return 'Preparación: $method · $dose g · $temp °C';
  }

  @override
  String brewingSummaryWithWater(
    String method,
    String dose,
    String water,
    String temp,
  ) {
    return 'Preparación: $method · $dose g · $water ml · $temp °C';
  }

  @override
  String grindingSummary(String grind, String grinder) {
    return 'Molienda: $grind · $grinder';
  }

  @override
  String kindAndName(String kind, String name) {
    return '$kind: $name';
  }

  @override
  String moreCount(int count) {
    return '+$count más';
  }

  @override
  String timerSummary(String minutes, String seconds) {
    return 'Temporizador: ${minutes}m ${seconds}s';
  }

  @override
  String get joinWithInvite => 'Unirse con invitación';

  @override
  String get createTeam => 'Crear equipo';

  @override
  String get noTeamsYet =>
      'Aún no hay equipos. Crea uno o únete con una invitación.';

  @override
  String ownerRole(String role) {
    return 'Dueño · $role';
  }

  @override
  String get create => 'Crear';

  @override
  String get inviteUrlOrToken => 'URL o token de invitación';

  @override
  String get join => 'Unirse';

  @override
  String get inviteToTeam => 'Invitar al equipo';

  @override
  String get inviteTtlOneHour => '1 h';

  @override
  String get inviteTtlOneDay => '24 h';

  @override
  String get inviteTtlOneWeek => '7 d';

  @override
  String get inviteLinkCopied => 'Enlace de invitación copiado';

  @override
  String inviteClipboardMessage(String team, String url) {
    return 'Te invito a unirte a $team en Cata Café. Allí compartimos recetas, notas de cata y las tazas que más nos gustan.\n\n$url';
  }

  @override
  String get copyLink => 'Copiar';

  @override
  String get singleUse => 'Un solo uso';

  @override
  String get teamFallback => 'Equipo';

  @override
  String get invite => 'Invitar';

  @override
  String get noRecipesOnTeam => 'Aún no hay recetas en este equipo.';

  @override
  String get teamInvite => 'Invitación al equipo';

  @override
  String youJoined(String team, String role) {
    return 'Te uniste a $team como $role.';
  }

  @override
  String get inviteNotFound => 'Invitación no encontrada.';

  @override
  String get openTeam => 'Abrir equipo';

  @override
  String validationNameLength(int max) {
    return 'El nombre debe tener entre 1 y $max caracteres';
  }

  @override
  String validationTagTooLong(int max) {
    return 'Una etiqueta debe tener como máximo $max caracteres';
  }

  @override
  String validationTooManyTags(int max) {
    return 'Máximo $max etiquetas';
  }

  @override
  String validationTooManyInstructions(int max) {
    return 'Máximo $max instrucciones';
  }

  @override
  String get validationEmptyInstruction =>
      'Una instrucción no puede estar vacía';

  @override
  String validationInstructionTooLong(int max) {
    return 'Una instrucción debe tener como máximo $max caracteres';
  }

  @override
  String get validationSelectIngredient =>
      'Selecciona o registra un ingrediente';

  @override
  String get validationAddTitle => 'Agrega un título';

  @override
  String validationWaterTemp(int min, int max) {
    return 'La temperatura del agua debe estar entre $min y $max °C';
  }

  @override
  String validationDose(String min, String max) {
    return 'La dosis debe estar entre $min y $max g';
  }

  @override
  String validationWaterQuantity(String min, String max) {
    return 'La cantidad de agua debe estar entre $min y $max ml';
  }

  @override
  String get validationAddGrindSize => 'Agrega un tamaño de molienda';

  @override
  String get validationAddGrinder => 'Agrega un modelo de molino';

  @override
  String get validationChooseMethod => 'Elige un método de extracción';

  @override
  String get validationDescribeMethod => 'Describe el método de extracción';

  @override
  String get validationExtractionTime =>
      'El tiempo de extracción debe estar entre 1 s y 2 h';

  @override
  String validationTooManyPhotos(int max) {
    return 'Máximo $max fotos';
  }

  @override
  String get accept => 'Aceptar';

  @override
  String get addToFavorites => 'Agregar a favoritos';

  @override
  String get removeFromFavorites => 'Quitar de favoritos';

  @override
  String get showFavorites => 'Mostrar favoritos';

  @override
  String get showAllRecipes => 'Mostrar todas las recetas';

  @override
  String get favoriteNameTakenTitle => 'Ya está en favoritos';

  @override
  String get favoriteNameTakenBody =>
      'Ya hay una receta con ese nombre en tus favoritos. ¿Quieres reemplazarla por esta?';

  @override
  String get noFavoriteRecipes => 'No hay recetas favoritas';

  @override
  String get noFavoriteRecipesDetail =>
      'Guarda una receta para conservar la versión que quieres preparar.';

  @override
  String get showTeamFavorites => 'Mostrar favoritos del equipo';

  @override
  String get showAllTeamRecipes => 'Mostrar todas las recetas del equipo';

  @override
  String get favoriteNameTakenTitleTeam =>
      'Ya está en los favoritos del equipo';

  @override
  String get favoriteNameTakenBodyTeam =>
      'Ya hay una receta con ese nombre en los favoritos de este equipo. ¿Quieres reemplazarla por esta?';

  @override
  String get noTeamFavoriteRecipes => 'No hay favoritos del equipo';

  @override
  String get noTeamFavoriteRecipesDetail =>
      'Los editores guardan la versión que el equipo prepara.';

  @override
  String get viewersCantChangeTeamFavorites =>
      'Los lectores no pueden cambiar los favoritos del equipo.';

  @override
  String get authSignInWithEmail => 'Iniciar sesión con correo electrónico';

  @override
  String get authEmail => 'Correo electrónico';

  @override
  String get authPreferredName => 'Nombre preferido';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authForgotPassword => 'Olvidé mi contraseña';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get authSignIn => 'Iniciar sesión';

  @override
  String get authDontHaveAnAccount => '¿No tienes una cuenta?';

  @override
  String get authContinue => 'Continuar';

  @override
  String get authAlreadyHaveAnAccount => '¿Ya tienes una cuenta?';

  @override
  String get authVerifyAccountTitle => 'Verificar cuenta';

  @override
  String get authVerifyResetCodeTitle => 'Verificar código';

  @override
  String get authVerificationMessage =>
      'Enviamos un correo de verificación. Revisa tu bandeja de entrada e ingresa el código a continuación. Si no lo encuentras, revisa la carpeta de spam.';

  @override
  String get authVerify => 'Verificar';

  @override
  String get authSetAccountPasswordTitle => 'Establecer contraseña';

  @override
  String get authBackToSignUp => 'Volver al registro';

  @override
  String get authSetNewPasswordTitle => 'Establecer nueva contraseña';

  @override
  String get authNewPassword => 'Nueva contraseña';

  @override
  String get authResetPasswordTitle => 'Restablecer contraseña';

  @override
  String get authResetPasswordDescription =>
      'Ingresa el correo electrónico para restablecer la contraseña.';

  @override
  String get authRequestPasswordReset => 'Solicitar restablecimiento';

  @override
  String get authResetPassword => 'Restablecer contraseña';

  @override
  String get authBackToSignIn => 'Volver a iniciar sesión';

  @override
  String get authTermsIntro => 'He leído y acepto los ';

  @override
  String get authTermsAndConditions => 'Términos y condiciones';

  @override
  String get authAnd => ' y la ';

  @override
  String get authPrivacyPolicy => 'Política de privacidad';

  @override
  String get authNoProviders =>
      'No hay proveedores de autenticación configurados';

  @override
  String get authOrContinueWith => 'o continuar con';

  @override
  String authPasswordMinLength(String length) {
    return 'Al menos $length caracteres';
  }

  @override
  String authPasswordMaxLength(String length) {
    return 'Como máximo $length caracteres';
  }

  @override
  String get authPasswordLowercase => 'Contiene al menos una letra minúscula';

  @override
  String get authPasswordUppercase => 'Contiene al menos una letra mayúscula';

  @override
  String get authPasswordNumber => 'Contiene al menos un número';

  @override
  String get authPasswordSpecial => 'Contiene al menos un carácter especial';
}
