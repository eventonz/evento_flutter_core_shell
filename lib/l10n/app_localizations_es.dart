// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get helloWorld => '¡Hola Mundo!';

  @override
  String get language => 'Idioma';

  @override
  String get askAQuestion => 'Hacer una pregunta';

  @override
  String get defaultAssistantMessage => 'Hazme cualquier pregunta sobre la guía del atleta - haré lo mejor para responder.';

  @override
  String get wouldYouLikeToRemoveAllMessages => '¿Te gustaría eliminar todos los mensajes?';

  @override
  String get yes => 'Sí';

  @override
  String get cancel => 'Cancelar';

  @override
  String get noResultFound => 'No se encontraron resultados';

  @override
  String get noImageFound => 'No se encontraron imágenes';

  @override
  String get somethingWentWrong => 'Algo salió mal';

  @override
  String get retry => 'Reintentar';

  @override
  String get splits => 'Divisiones';

  @override
  String get followNotAvailableUntilRaceNumberIsAssigned => 'Seguir no está disponible hasta que se asigne un número de carrera';

  @override
  String get follow => 'Seguir';

  @override
  String get following => 'Siguiendo';

  @override
  String get searchForAthletesUsingNameOrRaceNo => 'Busca aquí a atletas,\nusando nombre o número de carrera';

  @override
  String get search => 'Buscar';

  @override
  String noAthletesBeingFollowed(Object athleteText) {
    return 'No se está siguiendo a \$$athleteText';
  }

  @override
  String whenYouFollowAthleteYouWillSeeThemHere(Object athleteText) {
    return 'Cuando sigas a \$$athleteText, los verás aquí.';
  }

  @override
  String noAthletesFoundAtPresent(Object athleteText) {
    return 'No se encontró \$$athleteText actualmente';
  }

  @override
  String noAthleteFound(Object athleteText) {
    return 'No se encontró \$$athleteText';
  }

  @override
  String get lastUpdated => 'Última actualización';

  @override
  String get getDirections => 'Obtener direcciones';

  @override
  String get distanceMarkers => 'Marcadores de distancia';

  @override
  String get mapStyle => 'Estilo de mapa';

  @override
  String get pointsOfInterest => 'Puntos de interés';

  @override
  String get trackingNotAvailable => 'Seguimiento no disponible';

  @override
  String get loadFailedClickRetry => '¡Carga fallida! Haz clic en reintentar.';

  @override
  String get releaseToLoadMore => 'suelta para cargar más';

  @override
  String get noMoreData => 'No hay más datos';

  @override
  String get wouldYouLikeToReceiveEventReleatedPushNotificationsForThisEvent => '¿Te gustaría recibir notificaciones relacionadas con este evento?';

  @override
  String get noThanks => 'No gracias';

  @override
  String get elevationProfile => 'Perfil de elevación';

  @override
  String get all => 'Todos';

  @override
  String get noInternetConnectionFoundMsg => 'No se encontró conexión a Internet.\nPor favor, revisa tu configuración.';

  @override
  String get reload => 'Recargar';

  @override
  String get oops => '¡Ups!';

  @override
  String get pleaseTryAgainLater => 'Por favor, inténtalo más tarde';

  @override
  String get gender => 'Género';

  @override
  String get category => 'Categoría';

  @override
  String get selectGenderFirst => 'Selecciona género primero';

  @override
  String get apply => 'Aplicar';

  @override
  String get clear => 'Limpiar';

  @override
  String get filter => 'Filtro';

  @override
  String get pos => 'Posición';

  @override
  String get name => 'Nombre';

  @override
  String get result => 'Resultado';

  @override
  String get noDataFound => 'No se encontraron datos';

  @override
  String get noScheduleFound => 'No se encontró horario';

  @override
  String get settings => 'Configuraciones';

  @override
  String get general => 'General';

  @override
  String get appTheme => 'Tema de la aplicación';

  @override
  String get reloadAthletes => 'Recargar atletas';

  @override
  String get notificationSettings => 'Configuración de notificaciones';

  @override
  String get eventUpdates => 'Actualizaciones del evento';

  @override
  String get version => 'Versión';

  @override
  String get selectAppTheme => 'Selecciona tema de la aplicación';

  @override
  String get system => 'Sistema';

  @override
  String get dark => 'Oscuro';

  @override
  String get light => 'Claro';

  @override
  String get homebutton => 'Inicio';

  @override
  String get athletesbutton => 'Atletas';

  @override
  String get riderbutton => 'Jinetes';

  @override
  String get participantsbutton => 'Participantes';

  @override
  String get trackingbutton => 'Seguimiento';

  @override
  String get resultsbutton => 'Resultados';

  @override
  String get menubutton => 'Menú';

  @override
  String get menu => 'Menu';

  @override
  String get diff => 'Diff';
}
