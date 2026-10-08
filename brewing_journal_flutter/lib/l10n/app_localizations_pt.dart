// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Cata Café';

  @override
  String get myRecipes => 'Minhas receitas';

  @override
  String get teams => 'Equipes';

  @override
  String get signOut => 'Sair';

  @override
  String get newRecipe => 'Nova receita';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get noRecipesYet => 'Ainda não há receitas';

  @override
  String get noRecipesYetDetail =>
      'Toque em Nova receita para registrar seu primeiro preparo.';

  @override
  String recipeByline(String author, String updated) {
    return '$author · $updated';
  }

  @override
  String get unknownAuthor => 'Autor desconhecido';

  @override
  String get pageNotFound => 'Esta página não existe.';

  @override
  String get goHome => 'Ir para o início';

  @override
  String get connectionError =>
      'Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente.';

  @override
  String get genericError => 'Algo deu errado. Tente novamente.';

  @override
  String get recipeNotFound => 'Receita não encontrada';

  @override
  String get cantEditRecipe => 'Você não pode editar esta receita';

  @override
  String get photoNotVerified =>
      'Não foi possível verificar a foto. Tente novamente ou pule.';

  @override
  String get inviteExpired =>
      'Este convite expirou. Peça um novo a quem administra a equipe.';

  @override
  String get inviteUsed => 'Este convite já foi usado.';

  @override
  String get alreadyMember => 'Você já faz parte desta equipe.';

  @override
  String get recipeNotFoundOrUnshared =>
      'Receita não encontrada ou que não está mais compartilhada com você';

  @override
  String get viewersCantChange =>
      'Leitores não podem alterar as receitas da equipe.';

  @override
  String get recipeCouldNotBeLoaded =>
      'Não foi possível carregar esta receita.';

  @override
  String get photoFormatUnsupported =>
      'Este formato de imagem não é compatível. Escolha um JPEG ou PNG.';

  @override
  String get coffee => 'Café';

  @override
  String get tea => 'Chá';

  @override
  String get matcha => 'Matcha';

  @override
  String get roastLight => 'Clara';

  @override
  String get roastMedium => 'Média';

  @override
  String get roastMediumDark => 'Média-escura';

  @override
  String get roastDark => 'Escura';

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
  String get methodMatchaWhisk => 'Batedor de matcha';

  @override
  String get methodOther => 'Outro';

  @override
  String get roleViewer => 'Leitor';

  @override
  String get roleEditor => 'Editor';

  @override
  String get stepBean => 'Grão';

  @override
  String get stepBrew => 'Preparo';

  @override
  String get stepFlavor => 'Sabor';

  @override
  String get stepSteps => 'Passos';

  @override
  String get stepPhotos => 'Fotos';

  @override
  String get editRecipe => 'Editar receita';

  @override
  String get close => 'Fechar';

  @override
  String get back => 'Voltar';

  @override
  String get finish => 'Concluir';

  @override
  String get next => 'Avançar';

  @override
  String get whatAreYouBrewing => 'O que você vai preparar?';

  @override
  String searchIngredient(String kind) {
    return 'Busque seu $kind';
  }

  @override
  String get nothingRegistered => 'Ainda não há nada cadastrado.';

  @override
  String noMatches(String query) {
    return 'Nenhum resultado para \"$query\".';
  }

  @override
  String registerNewKind(String kind) {
    return 'Cadastrar novo $kind';
  }

  @override
  String get nameLabel => 'Nome';

  @override
  String get originOptional => 'Origem (opcional)';

  @override
  String get roasterOptional => 'Torrador ou produtor (opcional)';

  @override
  String get roastLevelOptional => 'Nível de torra (opcional)';

  @override
  String get notSet => 'Não definido';

  @override
  String get processingOptional => 'Processo (opcional)';

  @override
  String get processingHint => 'Lavado, natural, cultivado à sombra…';

  @override
  String get register => 'Cadastrar';

  @override
  String get brewParameters => 'Parâmetros de preparo';

  @override
  String get recipeTitle => 'Título da receita';

  @override
  String get waterTemperature => 'Temperatura da água';

  @override
  String get dose => 'Dose';

  @override
  String get waterQuantity => 'Quantidade de água';

  @override
  String get grindSize => 'Tamanho da moagem';

  @override
  String get grindSizeHint => 'Média-fina, 18 cliques…';

  @override
  String get grinderModel => 'Modelo do moedor';

  @override
  String get grinderModelHint => 'Comandante C40, Niche Zero…';

  @override
  String get extractionMethodLabel => 'Método de extração';

  @override
  String get describeTheMethod => 'Descreva o método';

  @override
  String get enterTime => 'Ou informe o tempo (m:ss)';

  @override
  String get timeFormatError => 'Use m:ss, por exemplo 2:30';

  @override
  String get extractionTime => 'Tempo de extração';

  @override
  String get stop => 'Parar';

  @override
  String get start => 'Iniciar';

  @override
  String get reset => 'Redefinir';

  @override
  String get flavorMap => 'Mapa de sabor';

  @override
  String get flavorTags => 'Etiquetas de sabor';

  @override
  String get addTagHint =>
      'Adicione uma etiqueta (frutado, chocolate, floral…)';

  @override
  String atMostTags(int count) {
    return 'No máximo $count etiquetas';
  }

  @override
  String get addTag => 'Adicionar etiqueta';

  @override
  String get acidity => 'Acidez';

  @override
  String get sweetness => 'Doçura';

  @override
  String get flavorBody => 'Corpo';

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
    return 'Mapa de sabor: acidez $acidity, doçura $sweetness, corpo $body, amargor $bitterness, de $maxScore';
  }

  @override
  String get extraSteps => 'Passos extras';

  @override
  String get skip => 'Pular';

  @override
  String get extraStepsHelp =>
      'Opcional. Qualquer coisa fora dos parâmetros de preparo, como \"usar 150 ml de leite integral\" ou \"adicionar canela e mexer\".';

  @override
  String atMostSteps(int count) {
    return 'No máximo $count passos';
  }

  @override
  String get addAStep => 'Adicione um passo';

  @override
  String get addStep => 'Adicionar passo';

  @override
  String get noExtraSteps => 'Ainda não há passos extras.';

  @override
  String get reorder => 'Reordenar';

  @override
  String get editStep => 'Editar passo';

  @override
  String get removeStep => 'Remover passo';

  @override
  String get stepCantBeEmpty => 'Um passo não pode ficar vazio';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get photos => 'Fotos';

  @override
  String photosHelp(int count) {
    return 'Opcional. Adicione até $count fotos da xícara, da crema ou da embalagem, ou toque em Concluir para salvar sem fotos.';
  }

  @override
  String get removePhoto => 'Remover foto';

  @override
  String get addPhoto => 'Adicionar foto';

  @override
  String get deleteRecipeTitle => 'Excluir esta receita?';

  @override
  String deleteRecipeBody(String title) {
    return '“$title” será removida. Essa ação não pode ser desfeita.';
  }

  @override
  String get delete => 'Excluir';

  @override
  String get createOrJoinTeam =>
      'Primeiro, crie uma equipe ou entre em uma como editor.';

  @override
  String get addToTeam => 'Adicionar à equipe';

  @override
  String get brewFallback => 'Preparo';

  @override
  String get share => 'Compartilhar';

  @override
  String get removeFromTeam => 'Remover da equipe';

  @override
  String get edit => 'Editar';

  @override
  String get prepAndExtraSteps => 'Preparo e passos extras';

  @override
  String get noExtractionTime => 'Nenhum tempo de extração registrado';

  @override
  String get extractionTimer => 'Temporizador de extração';

  @override
  String targetDuration(String time) {
    return 'Meta $time';
  }

  @override
  String get countDown => 'Contagem regressiva';

  @override
  String get countUp => 'Contagem progressiva';

  @override
  String get stopAlarm => 'Parar alarme';

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Retomar';

  @override
  String get couldNotCreateShareImage =>
      'Não foi possível criar a imagem para compartilhar.';

  @override
  String get couldNotSaveImage => 'Não foi possível salvar a imagem.';

  @override
  String get sharingNotSupported =>
      'Não é possível compartilhar aqui. Baixe a imagem.';

  @override
  String get downloadImage => 'Baixar imagem';

  @override
  String get madeWithBrewSync => 'Feito com Cata Café';

  @override
  String brewingSummary(String method, String dose, String temp) {
    return 'Preparo: $method · $dose g · $temp °C';
  }

  @override
  String brewingSummaryWithWater(
    String method,
    String dose,
    String water,
    String temp,
  ) {
    return 'Preparo: $method · $dose g · $water ml · $temp °C';
  }

  @override
  String grindingSummary(String grind, String grinder) {
    return 'Moagem: $grind · $grinder';
  }

  @override
  String kindAndName(String kind, String name) {
    return '$kind: $name';
  }

  @override
  String moreCount(int count) {
    return '+$count mais';
  }

  @override
  String timerSummary(String minutes, String seconds) {
    return 'Temporizador: ${minutes}m ${seconds}s';
  }

  @override
  String get joinWithInvite => 'Entrar com convite';

  @override
  String get createTeam => 'Criar equipe';

  @override
  String get noTeamsYet =>
      'Ainda não há equipes. Crie uma ou entre com um convite.';

  @override
  String ownerRole(String role) {
    return 'Dono · $role';
  }

  @override
  String get create => 'Criar';

  @override
  String get inviteUrlOrToken => 'URL ou token do convite';

  @override
  String get join => 'Entrar';

  @override
  String get inviteToTeam => 'Convidar para a equipe';

  @override
  String get inviteTtlOneHour => '1 h';

  @override
  String get inviteTtlOneDay => '24 h';

  @override
  String get inviteTtlOneWeek => '7 d';

  @override
  String get inviteLinkCopied => 'Link do convite copiado';

  @override
  String get copyLink => 'Copiar';

  @override
  String get singleUse => 'Uso único';

  @override
  String get teamFallback => 'Equipe';

  @override
  String get invite => 'Convidar';

  @override
  String get noRecipesOnTeam => 'Ainda não há receitas nesta equipe.';

  @override
  String get teamInvite => 'Convite da equipe';

  @override
  String youJoined(String team, String role) {
    return 'Você entrou em $team como $role.';
  }

  @override
  String get inviteNotFound => 'Convite não encontrado.';

  @override
  String get openTeam => 'Abrir equipe';

  @override
  String validationNameLength(int max) {
    return 'O nome deve ter de 1 a $max caracteres';
  }

  @override
  String validationTagTooLong(int max) {
    return 'Uma etiqueta deve ter no máximo $max caracteres';
  }

  @override
  String validationTooManyTags(int max) {
    return 'No máximo $max etiquetas';
  }

  @override
  String validationTooManyInstructions(int max) {
    return 'No máximo $max instruções';
  }

  @override
  String get validationEmptyInstruction => 'Uma instrução não pode ficar vazia';

  @override
  String validationInstructionTooLong(int max) {
    return 'Uma instrução deve ter no máximo $max caracteres';
  }

  @override
  String get validationSelectIngredient =>
      'Selecione ou cadastre um ingrediente';

  @override
  String get validationAddTitle => 'Adicione um título';

  @override
  String validationWaterTemp(int min, int max) {
    return 'A temperatura da água deve estar entre $min e $max °C';
  }

  @override
  String validationDose(String min, String max) {
    return 'A dose deve estar entre $min e $max g';
  }

  @override
  String validationWaterQuantity(String min, String max) {
    return 'A quantidade de água deve estar entre $min e $max ml';
  }

  @override
  String get validationAddGrindSize => 'Adicione um tamanho de moagem';

  @override
  String get validationAddGrinder => 'Adicione um modelo de moedor';

  @override
  String get validationChooseMethod => 'Escolha um método de extração';

  @override
  String get validationDescribeMethod => 'Descreva o método de extração';

  @override
  String get validationExtractionTime =>
      'O tempo de extração deve estar entre 1 s e 2 h';

  @override
  String validationTooManyPhotos(int max) {
    return 'No máximo $max fotos';
  }

  @override
  String get accept => 'Aceitar';

  @override
  String get addToFavorites => 'Adicionar aos favoritos';

  @override
  String get removeFromFavorites => 'Remover dos favoritos';

  @override
  String get showFavorites => 'Mostrar favoritos';

  @override
  String get showAllRecipes => 'Mostrar todas as receitas';

  @override
  String get favoriteNameTakenTitle => 'Já está nos favoritos';

  @override
  String get favoriteNameTakenBody =>
      'Já existe uma receita com esse nome nos seus favoritos. Deseja substituí-la por esta?';

  @override
  String get noFavoriteRecipes => 'Nenhuma receita favorita';

  @override
  String get noFavoriteRecipesDetail =>
      'Salve uma receita para guardar a versão que você quer preparar.';

  @override
  String get showTeamFavorites => 'Mostrar favoritos da equipe';

  @override
  String get showAllTeamRecipes => 'Mostrar todas as receitas da equipe';

  @override
  String get favoriteNameTakenTitleTeam => 'Já está nos favoritos da equipe';

  @override
  String get favoriteNameTakenBodyTeam =>
      'Já existe uma receita com esse nome nos favoritos desta equipe. Deseja substituí-la por esta?';

  @override
  String get noTeamFavoriteRecipes => 'Nenhum favorito da equipe';

  @override
  String get noTeamFavoriteRecipesDetail =>
      'Os editores salvam a versão que a equipe prepara.';

  @override
  String get viewersCantChangeTeamFavorites =>
      'Leitores não podem alterar os favoritos da equipe.';

  @override
  String get authSignInWithEmail => 'Entrar com e-mail';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authPreferredName => 'Nome preferido';

  @override
  String get authPassword => 'Senha';

  @override
  String get authForgotPassword => 'Esqueci a senha';

  @override
  String get authCreateAccount => 'Criar conta';

  @override
  String get authSignIn => 'Entrar';

  @override
  String get authDontHaveAnAccount => 'Não tem uma conta?';

  @override
  String get authContinue => 'Continuar';

  @override
  String get authAlreadyHaveAnAccount => 'Já tem uma conta?';

  @override
  String get authVerifyAccountTitle => 'Verificar conta';

  @override
  String get authVerifyResetCodeTitle => 'Verificar código';

  @override
  String get authVerificationMessage =>
      'Enviamos um e-mail de verificação. Confira seu e-mail e digite o código abaixo.';

  @override
  String get authVerify => 'Verificar';

  @override
  String get authSetAccountPasswordTitle => 'Definir senha da conta';

  @override
  String get authBackToSignUp => 'Voltar ao cadastro';

  @override
  String get authSetNewPasswordTitle => 'Definir nova senha';

  @override
  String get authNewPassword => 'Nova senha';

  @override
  String get authResetPasswordTitle => 'Redefinir senha';

  @override
  String get authResetPasswordDescription =>
      'Digite o e-mail para redefinir a senha.';

  @override
  String get authRequestPasswordReset => 'Solicitar redefinição de senha';

  @override
  String get authResetPassword => 'Redefinir senha';

  @override
  String get authBackToSignIn => 'Voltar para entrar';

  @override
  String get authTermsIntro => 'Li e aceito os ';

  @override
  String get authTermsAndConditions => 'Termos e Condições';

  @override
  String get authAnd => ' e a ';

  @override
  String get authPrivacyPolicy => 'Política de Privacidade';

  @override
  String get authNoProviders => 'Nenhum provedor de autenticação configurado';

  @override
  String get authOrContinueWith => 'ou continuar com';

  @override
  String authPasswordMinLength(String length) {
    return 'Pelo menos $length caracteres';
  }

  @override
  String authPasswordMaxLength(String length) {
    return 'No máximo $length caracteres';
  }

  @override
  String get authPasswordLowercase => 'Contém pelo menos uma letra minúscula';

  @override
  String get authPasswordUppercase => 'Contém pelo menos uma letra maiúscula';

  @override
  String get authPasswordNumber => 'Contém pelo menos um número';

  @override
  String get authPasswordSpecial => 'Contém pelo menos um caractere especial';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'Cata Café';

  @override
  String get myRecipes => 'Minhas receitas';

  @override
  String get teams => 'Equipes';

  @override
  String get signOut => 'Sair';

  @override
  String get newRecipe => 'Nova receita';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get noRecipesYet => 'Ainda não há receitas';

  @override
  String get noRecipesYetDetail =>
      'Toque em Nova receita para registrar seu primeiro preparo.';

  @override
  String recipeByline(String author, String updated) {
    return '$author · $updated';
  }

  @override
  String get unknownAuthor => 'Autor desconhecido';

  @override
  String get pageNotFound => 'Esta página não existe.';

  @override
  String get goHome => 'Ir para o início';

  @override
  String get connectionError =>
      'Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente.';

  @override
  String get genericError => 'Algo deu errado. Tente novamente.';

  @override
  String get recipeNotFound => 'Receita não encontrada';

  @override
  String get cantEditRecipe => 'Você não pode editar esta receita';

  @override
  String get photoNotVerified =>
      'Não foi possível verificar a foto. Tente novamente ou pule.';

  @override
  String get inviteExpired =>
      'Este convite expirou. Peça um novo a quem administra a equipe.';

  @override
  String get inviteUsed => 'Este convite já foi usado.';

  @override
  String get alreadyMember => 'Você já faz parte desta equipe.';

  @override
  String get recipeNotFoundOrUnshared =>
      'Receita não encontrada ou que não está mais compartilhada com você';

  @override
  String get viewersCantChange =>
      'Leitores não podem alterar as receitas da equipe.';

  @override
  String get recipeCouldNotBeLoaded =>
      'Não foi possível carregar esta receita.';

  @override
  String get photoFormatUnsupported =>
      'Este formato de imagem não é compatível. Escolha um JPEG ou PNG.';

  @override
  String get coffee => 'Café';

  @override
  String get tea => 'Chá';

  @override
  String get matcha => 'Matcha';

  @override
  String get roastLight => 'Clara';

  @override
  String get roastMedium => 'Média';

  @override
  String get roastMediumDark => 'Média-escura';

  @override
  String get roastDark => 'Escura';

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
  String get methodMatchaWhisk => 'Batedor de matcha';

  @override
  String get methodOther => 'Outro';

  @override
  String get roleViewer => 'Leitor';

  @override
  String get roleEditor => 'Editor';

  @override
  String get stepBean => 'Grão';

  @override
  String get stepBrew => 'Preparo';

  @override
  String get stepFlavor => 'Sabor';

  @override
  String get stepSteps => 'Passos';

  @override
  String get stepPhotos => 'Fotos';

  @override
  String get editRecipe => 'Editar receita';

  @override
  String get close => 'Fechar';

  @override
  String get back => 'Voltar';

  @override
  String get finish => 'Concluir';

  @override
  String get next => 'Avançar';

  @override
  String get whatAreYouBrewing => 'O que você vai preparar?';

  @override
  String searchIngredient(String kind) {
    return 'Busque seu $kind';
  }

  @override
  String get nothingRegistered => 'Ainda não há nada cadastrado.';

  @override
  String noMatches(String query) {
    return 'Nenhum resultado para \"$query\".';
  }

  @override
  String registerNewKind(String kind) {
    return 'Cadastrar novo $kind';
  }

  @override
  String get nameLabel => 'Nome';

  @override
  String get originOptional => 'Origem (opcional)';

  @override
  String get roasterOptional => 'Torrador ou produtor (opcional)';

  @override
  String get roastLevelOptional => 'Nível de torra (opcional)';

  @override
  String get notSet => 'Não definido';

  @override
  String get processingOptional => 'Processo (opcional)';

  @override
  String get processingHint => 'Lavado, natural, cultivado à sombra…';

  @override
  String get register => 'Cadastrar';

  @override
  String get brewParameters => 'Parâmetros de preparo';

  @override
  String get recipeTitle => 'Título da receita';

  @override
  String get waterTemperature => 'Temperatura da água';

  @override
  String get dose => 'Dose';

  @override
  String get waterQuantity => 'Quantidade de água';

  @override
  String get grindSize => 'Tamanho da moagem';

  @override
  String get grindSizeHint => 'Média-fina, 18 cliques…';

  @override
  String get grinderModel => 'Modelo do moedor';

  @override
  String get grinderModelHint => 'Comandante C40, Niche Zero…';

  @override
  String get extractionMethodLabel => 'Método de extração';

  @override
  String get describeTheMethod => 'Descreva o método';

  @override
  String get enterTime => 'Ou informe o tempo (m:ss)';

  @override
  String get timeFormatError => 'Use m:ss, por exemplo 2:30';

  @override
  String get extractionTime => 'Tempo de extração';

  @override
  String get stop => 'Parar';

  @override
  String get start => 'Iniciar';

  @override
  String get reset => 'Redefinir';

  @override
  String get flavorMap => 'Mapa de sabor';

  @override
  String get flavorTags => 'Etiquetas de sabor';

  @override
  String get addTagHint =>
      'Adicione uma etiqueta (frutado, chocolate, floral…)';

  @override
  String atMostTags(int count) {
    return 'No máximo $count etiquetas';
  }

  @override
  String get addTag => 'Adicionar etiqueta';

  @override
  String get acidity => 'Acidez';

  @override
  String get sweetness => 'Doçura';

  @override
  String get flavorBody => 'Corpo';

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
    return 'Mapa de sabor: acidez $acidity, doçura $sweetness, corpo $body, amargor $bitterness, de $maxScore';
  }

  @override
  String get extraSteps => 'Passos extras';

  @override
  String get skip => 'Pular';

  @override
  String get extraStepsHelp =>
      'Opcional. Qualquer coisa fora dos parâmetros de preparo, como \"usar 150 ml de leite integral\" ou \"adicionar canela e mexer\".';

  @override
  String atMostSteps(int count) {
    return 'No máximo $count passos';
  }

  @override
  String get addAStep => 'Adicione um passo';

  @override
  String get addStep => 'Adicionar passo';

  @override
  String get noExtraSteps => 'Ainda não há passos extras.';

  @override
  String get reorder => 'Reordenar';

  @override
  String get editStep => 'Editar passo';

  @override
  String get removeStep => 'Remover passo';

  @override
  String get stepCantBeEmpty => 'Um passo não pode ficar vazio';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get photos => 'Fotos';

  @override
  String photosHelp(int count) {
    return 'Opcional. Adicione até $count fotos da xícara, da crema ou da embalagem, ou toque em Concluir para salvar sem fotos.';
  }

  @override
  String get removePhoto => 'Remover foto';

  @override
  String get addPhoto => 'Adicionar foto';

  @override
  String get deleteRecipeTitle => 'Excluir esta receita?';

  @override
  String deleteRecipeBody(String title) {
    return '“$title” será removida. Essa ação não pode ser desfeita.';
  }

  @override
  String get delete => 'Excluir';

  @override
  String get createOrJoinTeam =>
      'Primeiro, crie uma equipe ou entre em uma como editor.';

  @override
  String get addToTeam => 'Adicionar à equipe';

  @override
  String get brewFallback => 'Preparo';

  @override
  String get share => 'Compartilhar';

  @override
  String get removeFromTeam => 'Remover da equipe';

  @override
  String get edit => 'Editar';

  @override
  String get prepAndExtraSteps => 'Preparo e passos extras';

  @override
  String get noExtractionTime => 'Nenhum tempo de extração registrado';

  @override
  String get extractionTimer => 'Temporizador de extração';

  @override
  String targetDuration(String time) {
    return 'Meta $time';
  }

  @override
  String get countDown => 'Contagem regressiva';

  @override
  String get countUp => 'Contagem progressiva';

  @override
  String get stopAlarm => 'Parar alarme';

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Retomar';

  @override
  String get couldNotCreateShareImage =>
      'Não foi possível criar a imagem para compartilhar.';

  @override
  String get couldNotSaveImage => 'Não foi possível salvar a imagem.';

  @override
  String get sharingNotSupported =>
      'Não é possível compartilhar aqui. Baixe a imagem.';

  @override
  String get downloadImage => 'Baixar imagem';

  @override
  String get madeWithBrewSync => 'Feito com Cata Café';

  @override
  String brewingSummary(String method, String dose, String temp) {
    return 'Preparo: $method · $dose g · $temp °C';
  }

  @override
  String brewingSummaryWithWater(
    String method,
    String dose,
    String water,
    String temp,
  ) {
    return 'Preparo: $method · $dose g · $water ml · $temp °C';
  }

  @override
  String grindingSummary(String grind, String grinder) {
    return 'Moagem: $grind · $grinder';
  }

  @override
  String kindAndName(String kind, String name) {
    return '$kind: $name';
  }

  @override
  String moreCount(int count) {
    return '+$count mais';
  }

  @override
  String timerSummary(String minutes, String seconds) {
    return 'Temporizador: ${minutes}m ${seconds}s';
  }

  @override
  String get joinWithInvite => 'Entrar com convite';

  @override
  String get createTeam => 'Criar equipe';

  @override
  String get noTeamsYet =>
      'Ainda não há equipes. Crie uma ou entre com um convite.';

  @override
  String ownerRole(String role) {
    return 'Dono · $role';
  }

  @override
  String get create => 'Criar';

  @override
  String get inviteUrlOrToken => 'URL ou token do convite';

  @override
  String get join => 'Entrar';

  @override
  String get inviteToTeam => 'Convidar para a equipe';

  @override
  String get inviteTtlOneHour => '1 h';

  @override
  String get inviteTtlOneDay => '24 h';

  @override
  String get inviteTtlOneWeek => '7 d';

  @override
  String get inviteLinkCopied => 'Link do convite copiado';

  @override
  String get copyLink => 'Copiar';

  @override
  String get singleUse => 'Uso único';

  @override
  String get teamFallback => 'Equipe';

  @override
  String get invite => 'Convidar';

  @override
  String get noRecipesOnTeam => 'Ainda não há receitas nesta equipe.';

  @override
  String get teamInvite => 'Convite da equipe';

  @override
  String youJoined(String team, String role) {
    return 'Você entrou em $team como $role.';
  }

  @override
  String get inviteNotFound => 'Convite não encontrado.';

  @override
  String get openTeam => 'Abrir equipe';

  @override
  String validationNameLength(int max) {
    return 'O nome deve ter de 1 a $max caracteres';
  }

  @override
  String validationTagTooLong(int max) {
    return 'Uma etiqueta deve ter no máximo $max caracteres';
  }

  @override
  String validationTooManyTags(int max) {
    return 'No máximo $max etiquetas';
  }

  @override
  String validationTooManyInstructions(int max) {
    return 'No máximo $max instruções';
  }

  @override
  String get validationEmptyInstruction => 'Uma instrução não pode ficar vazia';

  @override
  String validationInstructionTooLong(int max) {
    return 'Uma instrução deve ter no máximo $max caracteres';
  }

  @override
  String get validationSelectIngredient =>
      'Selecione ou cadastre um ingrediente';

  @override
  String get validationAddTitle => 'Adicione um título';

  @override
  String validationWaterTemp(int min, int max) {
    return 'A temperatura da água deve estar entre $min e $max °C';
  }

  @override
  String validationDose(String min, String max) {
    return 'A dose deve estar entre $min e $max g';
  }

  @override
  String validationWaterQuantity(String min, String max) {
    return 'A quantidade de água deve estar entre $min e $max ml';
  }

  @override
  String get validationAddGrindSize => 'Adicione um tamanho de moagem';

  @override
  String get validationAddGrinder => 'Adicione um modelo de moedor';

  @override
  String get validationChooseMethod => 'Escolha um método de extração';

  @override
  String get validationDescribeMethod => 'Descreva o método de extração';

  @override
  String get validationExtractionTime =>
      'O tempo de extração deve estar entre 1 s e 2 h';

  @override
  String validationTooManyPhotos(int max) {
    return 'No máximo $max fotos';
  }

  @override
  String get accept => 'Aceitar';

  @override
  String get addToFavorites => 'Adicionar aos favoritos';

  @override
  String get removeFromFavorites => 'Remover dos favoritos';

  @override
  String get showFavorites => 'Mostrar favoritos';

  @override
  String get showAllRecipes => 'Mostrar todas as receitas';

  @override
  String get favoriteNameTakenTitle => 'Já está nos favoritos';

  @override
  String get favoriteNameTakenBody =>
      'Já existe uma receita com esse nome nos seus favoritos. Deseja substituí-la por esta?';

  @override
  String get noFavoriteRecipes => 'Nenhuma receita favorita';

  @override
  String get noFavoriteRecipesDetail =>
      'Salve uma receita para guardar a versão que você quer preparar.';

  @override
  String get showTeamFavorites => 'Mostrar favoritos da equipe';

  @override
  String get showAllTeamRecipes => 'Mostrar todas as receitas da equipe';

  @override
  String get favoriteNameTakenTitleTeam => 'Já está nos favoritos da equipe';

  @override
  String get favoriteNameTakenBodyTeam =>
      'Já existe uma receita com esse nome nos favoritos desta equipe. Deseja substituí-la por esta?';

  @override
  String get noTeamFavoriteRecipes => 'Nenhum favorito da equipe';

  @override
  String get noTeamFavoriteRecipesDetail =>
      'Os editores salvam a versão que a equipe prepara.';

  @override
  String get viewersCantChangeTeamFavorites =>
      'Leitores não podem alterar os favoritos da equipe.';

  @override
  String get authSignInWithEmail => 'Entrar com e-mail';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authPreferredName => 'Nome preferido';

  @override
  String get authPassword => 'Senha';

  @override
  String get authForgotPassword => 'Esqueci a senha';

  @override
  String get authCreateAccount => 'Criar conta';

  @override
  String get authSignIn => 'Entrar';

  @override
  String get authDontHaveAnAccount => 'Não tem uma conta?';

  @override
  String get authContinue => 'Continuar';

  @override
  String get authAlreadyHaveAnAccount => 'Já tem uma conta?';

  @override
  String get authVerifyAccountTitle => 'Verificar conta';

  @override
  String get authVerifyResetCodeTitle => 'Verificar código';

  @override
  String get authVerificationMessage =>
      'Enviamos um e-mail de verificação. Confira seu e-mail e digite o código abaixo.';

  @override
  String get authVerify => 'Verificar';

  @override
  String get authSetAccountPasswordTitle => 'Definir senha da conta';

  @override
  String get authBackToSignUp => 'Voltar ao cadastro';

  @override
  String get authSetNewPasswordTitle => 'Definir nova senha';

  @override
  String get authNewPassword => 'Nova senha';

  @override
  String get authResetPasswordTitle => 'Redefinir senha';

  @override
  String get authResetPasswordDescription =>
      'Digite o e-mail para redefinir a senha.';

  @override
  String get authRequestPasswordReset => 'Solicitar redefinição de senha';

  @override
  String get authResetPassword => 'Redefinir senha';

  @override
  String get authBackToSignIn => 'Voltar para entrar';

  @override
  String get authTermsIntro => 'Li e aceito os ';

  @override
  String get authTermsAndConditions => 'Termos e Condições';

  @override
  String get authAnd => ' e a ';

  @override
  String get authPrivacyPolicy => 'Política de Privacidade';

  @override
  String get authNoProviders => 'Nenhum provedor de autenticação configurado';

  @override
  String get authOrContinueWith => 'ou continuar com';

  @override
  String authPasswordMinLength(String length) {
    return 'Pelo menos $length caracteres';
  }

  @override
  String authPasswordMaxLength(String length) {
    return 'No máximo $length caracteres';
  }

  @override
  String get authPasswordLowercase => 'Contém pelo menos uma letra minúscula';

  @override
  String get authPasswordUppercase => 'Contém pelo menos uma letra maiúscula';

  @override
  String get authPasswordNumber => 'Contém pelo menos um número';

  @override
  String get authPasswordSpecial => 'Contém pelo menos um caractere especial';
}
