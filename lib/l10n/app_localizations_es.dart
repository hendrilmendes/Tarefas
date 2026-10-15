// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Tá na Lista';

  @override
  String get home => 'Tareas';

  @override
  String get notes => 'Notas';

  @override
  String get settings => 'Ajustes';

  @override
  String get googleLogin => 'Iniciar sesión con Google';

  @override
  String get ok => 'OK';

  @override
  String get newTask => 'Nueva tarea';

  @override
  String get newNote => 'Nueva nota';

  @override
  String get saveNote => '¡Nota guardada con éxito!';

  @override
  String get errosaveNote => 'Error al guardar la nota.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get save => 'Guardar';

  @override
  String get notesDetails => 'Detalles de la nota';

  @override
  String get inputTask => 'Escribe tu tarea';

  @override
  String get inputNote => 'Escribe tu nota';

  @override
  String get errorLoadNotes => 'Error al cargar las notas';

  @override
  String get noTask => 'No se encontraron tareas';

  @override
  String get noNotes => 'No se encontraron notas';

  @override
  String get confirmDelete => 'Confirmar eliminación';

  @override
  String get confirmDeleteNote => '¿Seguro que quieres eliminar esta nota?';

  @override
  String get about => 'Acerca de';

  @override
  String get copyright => 'Todos los derechos reservados';

  @override
  String get appDesc => 'Organiza tus tareas y notas diarias.';

  @override
  String get version => 'Versión';

  @override
  String get privacy => 'Política de privacidad';

  @override
  String get privacySub => 'Términos que garantizan tu privacidad';

  @override
  String get sourceCode => 'Código fuente';

  @override
  String get sourceCodeSub => 'Proyecto disponible en GitHub';

  @override
  String get openSource => 'Licencias de código abierto';

  @override
  String get openSourceSub => 'Software de terceros usado en la app';

  @override
  String get interface => 'Interfaz';

  @override
  String get others => 'Otros';

  @override
  String get theme => 'Tema';

  @override
  String get themeSelect => 'Elige el tema';

  @override
  String get darkMode => 'Oscuro';

  @override
  String get lightMode => 'Claro';

  @override
  String get systemMode => 'Sistema';

  @override
  String get dynamicColors => 'Dynamic Colors';

  @override
  String get dynamicColorsSub =>
      'Ofrece una interfaz agradable según tu fondo de pantalla';

  @override
  String get update => 'Actualizaciones';

  @override
  String get updateSub => 'Buscar nuevas versiones de la app';

  @override
  String get support => 'Soporte';

  @override
  String get supportSub => '¿Encontraste un error o quieres sugerir algo?';

  @override
  String get review => 'Valora la app';

  @override
  String get reviewSub => 'Deja una reseña en la tienda de apps';

  @override
  String get aboutSub => 'Un poco más sobre la app';

  @override
  String get newUpdate => 'Nueva versión disponible';

  @override
  String get news => 'Novedades:';

  @override
  String get after => 'DESPUÉS';

  @override
  String get download => 'DESCARGAR';

  @override
  String get noUpdate => 'No hay actualizaciones disponibles';

  @override
  String get noUpdateSub => 'Ya tienes la última versión de la app';

  @override
  String get pendants => 'Pendientes';

  @override
  String get completed => 'Completadas';

  @override
  String get dateTime => 'Selecciona fecha y hora';

  @override
  String get taskDetails => 'Detalles de la tarea';

  @override
  String get notificationTask => 'No lo olvides';

  @override
  String get error => 'Error';

  @override
  String get inputDateError => 'La fecha y la hora son obligatorias';

  @override
  String get inputTaskError => 'No se puede añadir una tarea vacía';

  @override
  String get inputNoteError => 'No se puede guardar una nota vacía';

  @override
  String get notification => 'Notificaciones';

  @override
  String get notificationSub => 'Notificaciones sobre tus tareas';

  @override
  String get confirmDeleteTask => '¿Realmente quieres eliminar la tarea?';

  @override
  String get share => 'Compartir';

  @override
  String get alreadyReviewed => 'Ya valoraste la app';

  @override
  String get dateTitle => 'Fecha de la tarea';

  @override
  String get noDate => 'Sin programar';

  @override
  String get taskTitle => 'Título de la tarea';

  @override
  String get errorUpdate => 'No se pudo buscar actualizaciones.';

  @override
  String get loading => 'Cargando...';

  @override
  String get loginError => 'Error de inicio de sesión';

  @override
  String get personalization => 'Personalización';

  @override
  String get personalizationSub => 'Personaliza la app como quieras';

  @override
  String get color => 'Color';

  @override
  String get accentColor => 'Color de acento';

  @override
  String get dynamicColorsEnabledWarning => 'Dynamic Colors está activado';

  @override
  String get information => 'Información';

  @override
  String get displayMode => 'Modo de visualización';

  @override
  String get addTasks => 'Toca el botón + para crear tu primera tarea';

  @override
  String get addNotes => 'Toca el botón + para crear tu primera nota';

  @override
  String get acceptTerms => 'Al continuar, aceptas nuestra ';

  @override
  String get welcomeMessageTitle => 'Organiza tu día,';

  @override
  String get welcomeMessageSub => 'alcanza tus objetivos.';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logoutConfirm => 'Desconectar';

  @override
  String get logoutConfirmSub => '¿Seguro que quieres desconectarte de la app?';

  @override
  String get greetingNight => 'Buenas madrugadas';

  @override
  String get greetingMorning => 'Buenos días';

  @override
  String get greetingAfternoon => 'Buenas tardes';

  @override
  String get greetingEvening => 'Buenas noches';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name 👋';
  }

  @override
  String get you => 'tú';

  @override
  String get briefingEmpty =>
      'Tu agenda está libre. ¿Qué tal planificar el día en 3 metas?';

  @override
  String briefingOverdueToday(int overdue, int today) {
    String _temp0 = intl.Intl.pluralLogic(
      overdue,
      locale: localeName,
      other: '$overdue tareas atrasadas',
      one: '1 tarea atrasada',
    );
    return 'Tienes $_temp0 y $today para hoy. Limpiemos primero las atrasadas.';
  }

  @override
  String briefingOverdue(int overdue) {
    String _temp0 = intl.Intl.pluralLogic(
      overdue,
      locale: localeName,
      other: '$overdue tareas atrasadas',
      one: '1 tarea atrasada',
    );
    return 'Tienes $_temp0. Te recomiendo reprogramar o terminar ahora.';
  }

  @override
  String briefingToday(int today) {
    String _temp0 = intl.Intl.pluralLogic(
      today,
      locale: localeName,
      other: '$today tareas',
      one: '1 tarea',
    );
    return 'Hoy tienes $_temp0. Buen ritmo — concéntrate en la primera de abajo.';
  }

  @override
  String briefingPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pendientes',
      one: '1 pendiente',
    );
    return 'Nada para hoy, pero hay $_temp0 por delante. ¿Qué tal adelantar una?';
  }

  @override
  String get briefingAllDone =>
      'Todo completado. Día despejado — aprovecha para revisar las notas.';

  @override
  String suggestionFocus(String title, String when) {
    return 'Sugerencia: empieza por \"$title\" ($when). Divídela en pasos de 10 min si te atascas.';
  }

  @override
  String get suggestionCreate =>
      'Sugerencia: crea 3 tareas con hora — ej.: \"Mañana 9h gimnasio #salud\".';

  @override
  String get whenNoTime => 'sin hora';

  @override
  String get whenOverdue => 'atrasada';

  @override
  String whenToday(String time) {
    return 'hoy a las $time';
  }

  @override
  String get whenTomorrow => 'mañana';

  @override
  String whenInDays(int days) {
    return 'en $days días';
  }

  @override
  String get stepsTravel =>
      'Definir fechas y presupuesto|Reservar transporte y alojamiento|Hacer lista de equipaje|Confirmar documentos';

  @override
  String get stepsStudy =>
      'Separar el material en 3 bloques|Estudiar el bloque 1 (25 min de foco)|Repasar con resúmenes|Hacer preguntas/ejercicios';

  @override
  String get stepsClean =>
      'Elegir 1 habitación|Separar lo que sale / se queda|Limpiar en 15 min|Guardar y fotografiar el resultado';

  @override
  String get stepsProject =>
      'Definir el objetivo en 1 frase|Esbozar la estructura|Completar el contenido|Revisar y enviar';

  @override
  String get stepsWorkout =>
      'Preparar ropa + agua|Calentar 5 min|Entrenamiento principal 20 min|Estirar y registrar';

  @override
  String get stepsBill =>
      'Revisar importe y vencimiento|Pagar en la app/banco|Guardar el comprobante';

  @override
  String get stepsGeneric =>
      'Definir el primer paso de 5 min|Ejecutar sin interrupciones|Revisar y marcar como hecho';

  @override
  String slotToday(String time) {
    return 'Hoy a las $time parece libre';
  }

  @override
  String get slotTomorrow => 'Mañana a las 09:00 parece ideal';

  @override
  String get priorityUrgent => 'Urgente';

  @override
  String get priorityHigh => 'Alta';

  @override
  String get priorityMedium => 'Media';

  @override
  String get priorityNormal => 'Normal';

  @override
  String get priority => 'Prioridad';

  @override
  String get overdue => 'Atrasadas';

  @override
  String get today => 'Hoy';

  @override
  String get tomorrow => 'Mañana';

  @override
  String get noDateGroup => 'Sin fecha';

  @override
  String get agenda => 'Agenda';

  @override
  String get agendaFreeTitle => 'Agenda libre por aquí';

  @override
  String agendaFreeBody(String tip) {
    return 'Nada en los próximos 14 días.\n$tip.';
  }

  @override
  String agendaCount(int count) {
    return '$count en la agenda';
  }

  @override
  String get focus => 'Foco';

  @override
  String get focusDone => '¡Foco completado! Hora del descanso ☕';

  @override
  String get breakDone => 'Descanso terminado. ¿Vamos al siguiente ciclo?';

  @override
  String get breakLabel => 'DESCANSO';

  @override
  String focusCycles(int cycles) {
    String _temp0 = intl.Intl.pluralLogic(
      cycles,
      locale: localeName,
      other: '$cycles ciclos',
      one: '1 ciclo',
    );
    return 'FOCO • $_temp0';
  }

  @override
  String get breakTip => 'Respira, estírate, bebe agua.';

  @override
  String get focusTip =>
      'Consejo de la IA: 1 tarea, móvil lejos, 25 min seguidos.';

  @override
  String get pause => 'Pausar';

  @override
  String get start => 'Empezar';

  @override
  String get reset => 'Reiniciar';

  @override
  String taskCreatedByAi(String title, int steps) {
    String _temp0 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps pasos sugeridos',
      one: '1 paso sugerido',
    );
    return 'Creada: \"$title\" • $_temp0 por la IA';
  }

  @override
  String errorSaving(String error) {
    return 'Error al guardar: $error';
  }

  @override
  String errorRemoving(String error) {
    return 'Error al eliminar: $error';
  }

  @override
  String errorDeleting(String error) {
    return 'Error al borrar: $error';
  }

  @override
  String errorUpdatingTask(String error) {
    return 'Error al actualizar la tarea: $error';
  }

  @override
  String get notificationChannelName => 'Recordatorios de tareas';

  @override
  String get notificationChannelDesc => 'Alertas de tareas programadas';

  @override
  String get updateFailed => 'Error al actualizar. Inténtalo de nuevo.';

  @override
  String get searchTasksHint => 'Buscar tarea o #proyecto…';

  @override
  String get filterAll => 'Todas';

  @override
  String get filterMyDay => 'Mi día';

  @override
  String get filterUpcoming => 'Próximas';

  @override
  String get filterDone => 'Hechas';

  @override
  String get emptyDone =>
      'Nada completado aún — completa la primera y vuelve aquí.';

  @override
  String get emptyTasks =>
      'Ninguna tarea aquí.\nToca el botón de abajo para añadir con lenguaje natural.';

  @override
  String get completedLabel => 'Completada';

  @override
  String get markAsCompleted => 'Marcar como completada';

  @override
  String get projectOptional => 'Proyecto (opcional)';

  @override
  String get projectHint => '#proyecto — casa, trabajo…';

  @override
  String get aiSuggestedSteps => 'Pasos sugeridos por la IA local';

  @override
  String get signInFailed => 'No se pudo iniciar sesión. Inténtalo de nuevo.';

  @override
  String get loginToday => 'Hoy';

  @override
  String get loginSample1 => 'Pagar la factura de luz';

  @override
  String get loginSample2 => 'Reunión 9h';

  @override
  String get loginSample3 => 'Gimnasio 18h';

  @override
  String get loginProgress => '2 de 3 completadas';

  @override
  String get loginBadgeTime => 'Lun 9:00';

  @override
  String get loginBadgeMeeting => 'Reunión';

  @override
  String get loginBadgeReminder => 'Recordatorio';

  @override
  String get loginBadgeGym => 'Gimnasio 18h';

  @override
  String get welcomeBack => 'Bienvenido de nuevo 👋';

  @override
  String get signInToSee => 'Inicia sesión para ver tus tareas de hoy.';

  @override
  String get notesTitle => 'Notas';

  @override
  String get searchNotesHint => 'Buscar en las notas…';

  @override
  String noNotesFor(String query) {
    return 'Ninguna nota para \"$query\".';
  }

  @override
  String get createNote => 'Crear nota';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String errorDeletingNote(String error) {
    return 'Error al borrar la nota: $error';
  }

  @override
  String agoDays(int count) {
    return 'hace ${count}d';
  }

  @override
  String agoHours(int count) {
    return 'hace ${count}h';
  }

  @override
  String agoMinutes(int count) {
    return 'hace ${count}min';
  }

  @override
  String get justNow => 'ahora mismo';

  @override
  String get saveNoteFailed => 'Error al guardar la nota. Inténtalo de nuevo.';

  @override
  String agoDaysLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return 'hace $_temp0';
  }

  @override
  String agoHoursLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horas',
      one: '1 hora',
    );
    return 'hace $_temp0';
  }

  @override
  String agoMinutesLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutos',
      one: '1 minuto',
    );
    return 'hace $_temp0';
  }

  @override
  String lastEdit(String when) {
    return 'Última edición: $when';
  }

  @override
  String get updateTaskFailed => 'Error al actualizar.';

  @override
  String get supportEmailSubject => '[Tarefas App] Soporte y comentarios';

  @override
  String get emailOpenFailed =>
      'No se pudo abrir la app de correo. Contacto: hendrilmendes2015@gmail.com';

  @override
  String get userFallback => 'Usuario';

  @override
  String get alerts => 'Alertas';

  @override
  String get sendEmail => 'Enviar correo';

  @override
  String get contactDeveloper => 'Habla con el desarrollador';

  @override
  String steps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasos',
      one: '1 paso',
    );
    return '$_temp0';
  }

  @override
  String get tabAgenda => 'Agenda';

  @override
  String get assistantBadge => 'ASISTENTE LOCAL';

  @override
  String get focusNow => 'FOCO AHORA';

  @override
  String get pomodoro => 'Pomodoro';

  @override
  String get quickAddEmpty =>
      'Escribe la tarea — ej.: Mañana 15h pagar factura #casa';

  @override
  String get quickAddTitle => 'Nueva tarea inteligente';

  @override
  String get quickAddHint => 'Ej.: Lunes 9h reunión #trabajo !p1';

  @override
  String get quickAddTip =>
      'Consejo: usa \"mañana 15h\", \"#proyecto\", \"!p1\" y la IA lo entiende sola.';

  @override
  String get noDateSuggestToday => 'Sin fecha — sugerir hoy';

  @override
  String suggestedSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasos sugeridos',
      one: '1 paso sugerido',
    );
    return '$_temp0';
  }

  @override
  String get priorityColon => 'Prioridad:';

  @override
  String get releaseNotesEmpty =>
      'No se encontraron notas de versión para esta versión.';

  @override
  String releaseNotesError(int code) {
    return 'Error al cargar las notas de versión. Código: $code';
  }

  @override
  String get releaseNotesConnection =>
      'Error al cargar. Comprueba tu conexión a internet.';

  @override
  String get language => 'Idioma';

  @override
  String get languageSub => 'Elige el idioma de la app';

  @override
  String get languageAuto => 'Automático (sistema)';

  @override
  String get stepsShopping =>
      'Listar artículos prioritarios|Revisar despensa y nevera|Fijar presupuesto máximo|Ir al supermercado o tienda';

  @override
  String get stepsMeeting =>
      'Definir agenda y objetivo|Reunir enlaces y presentaciones|Enviar invitación/recordatorio|Anotar minuta y próximos pasos';

  @override
  String get stepsCoding =>
      'Entender requisitos y casos límite|Crear branch y escribir código|Probar localmente escenarios de error|Abrir PR y pedir revisión';

  @override
  String get stepsFinance =>
      'Revisar estado de cuenta|Categorizar ingresos y gastos|Identificar gastos innecesarios|Actualizar planilla o app financiera';

  @override
  String get stepsHealth =>
      'Agendar cita o examen médico|Juntar exámenes anteriores|Anotar dudas para el médico|Confirmar hora y trayecto';

  @override
  String get noteTotalDetected => 'Total detectado:';

  @override
  String noteValuesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valores',
      one: '1 valor',
    );
    return '$_temp0';
  }

  @override
  String get insertTotalInNote => 'Insertar total en la nota';
}
