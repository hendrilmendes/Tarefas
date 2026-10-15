// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Tá na Lista';

  @override
  String get home => 'Tasks';

  @override
  String get notes => 'Notes';

  @override
  String get settings => 'Settings';

  @override
  String get googleLogin => 'Sign in with Google';

  @override
  String get ok => 'OK';

  @override
  String get newTask => 'New Task';

  @override
  String get newNote => 'New Note';

  @override
  String get saveNote => 'Note saved successfully!';

  @override
  String get errosaveNote => 'Error saving note.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get notesDetails => 'Note Details';

  @override
  String get inputTask => 'Enter your task';

  @override
  String get inputNote => 'Enter your note';

  @override
  String get errorLoadNotes => 'Error loading notes';

  @override
  String get noTask => 'No tasks found';

  @override
  String get noNotes => 'No notes found';

  @override
  String get confirmDelete => 'Confirm deletion';

  @override
  String get confirmDeleteNote => 'Are you sure you want to delete this note?';

  @override
  String get about => 'About';

  @override
  String get copyright => 'All rights reserved';

  @override
  String get appDesc => 'Organize your daily tasks and notes.';

  @override
  String get version => 'Version';

  @override
  String get privacy => 'Privacy Policy';

  @override
  String get privacySub => 'Terms that protect your privacy';

  @override
  String get sourceCode => 'Source Code';

  @override
  String get sourceCodeSub => 'Project available on GitHub';

  @override
  String get openSource => 'Open Source Licenses';

  @override
  String get openSourceSub => 'Third-party software used in the app';

  @override
  String get interface => 'Interface';

  @override
  String get others => 'Others';

  @override
  String get theme => 'Theme';

  @override
  String get themeSelect => 'Choose Theme';

  @override
  String get darkMode => 'Dark';

  @override
  String get lightMode => 'Light';

  @override
  String get systemMode => 'System';

  @override
  String get dynamicColors => 'Dynamic Colors';

  @override
  String get dynamicColorsSub =>
      'Provides a pleasant interface that matches your wallpaper';

  @override
  String get update => 'Updates';

  @override
  String get updateSub => 'Check for new app versions';

  @override
  String get support => 'Support';

  @override
  String get supportSub => 'Found a bug or want to suggest something?';

  @override
  String get review => 'Rate the App';

  @override
  String get reviewSub => 'Leave a review on the app store';

  @override
  String get aboutSub => 'A little more about the app';

  @override
  String get newUpdate => 'New version available';

  @override
  String get news => 'What\'s new:';

  @override
  String get after => 'LATER';

  @override
  String get download => 'DOWNLOAD';

  @override
  String get noUpdate => 'No updates available';

  @override
  String get noUpdateSub => 'You already have the latest version of the app';

  @override
  String get pendants => 'Pending';

  @override
  String get completed => 'Completed';

  @override
  String get dateTime => 'Select date and time';

  @override
  String get taskDetails => 'Task Details';

  @override
  String get notificationTask => 'Don\'t forget';

  @override
  String get error => 'Error';

  @override
  String get inputDateError => 'Date and time are required';

  @override
  String get inputTaskError => 'Cannot add a blank task';

  @override
  String get inputNoteError => 'Cannot save a blank note';

  @override
  String get notification => 'Notifications';

  @override
  String get notificationSub => 'Notifications about your tasks';

  @override
  String get confirmDeleteTask => 'Do you really want to delete the task?';

  @override
  String get share => 'Share';

  @override
  String get alreadyReviewed => 'You have already rated the app';

  @override
  String get dateTitle => 'Task Date';

  @override
  String get noDate => 'No Schedule';

  @override
  String get taskTitle => 'Task Title';

  @override
  String get errorUpdate => 'Could not check for updates.';

  @override
  String get loading => 'Loading...';

  @override
  String get loginError => 'Login error';

  @override
  String get personalization => 'Personalization';

  @override
  String get personalizationSub => 'Customize the app the way you want';

  @override
  String get color => 'Color';

  @override
  String get accentColor => 'Accent Color';

  @override
  String get dynamicColorsEnabledWarning => 'Dynamic Colors is enabled';

  @override
  String get information => 'Information';

  @override
  String get displayMode => 'Display Mode';

  @override
  String get addTasks => 'Tap the + button to create your first task';

  @override
  String get addNotes => 'Tap the + button to create your first note';

  @override
  String get acceptTerms => 'By continuing, you agree to our ';

  @override
  String get welcomeMessageTitle => 'Organize your day,';

  @override
  String get welcomeMessageSub => 'reach your goals.';

  @override
  String get logout => 'Sign out';

  @override
  String get logoutConfirm => 'Disconnect';

  @override
  String get logoutConfirmSub =>
      'Are you sure you want to disconnect from the app?';

  @override
  String get greetingNight => 'Good night';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name 👋';
  }

  @override
  String get you => 'you';

  @override
  String get briefingEmpty =>
      'Your schedule is clear. How about planning the day in 3 goals?';

  @override
  String briefingOverdueToday(int overdue, int today) {
    String _temp0 = intl.Intl.pluralLogic(
      overdue,
      locale: localeName,
      other: '$overdue overdue tasks',
      one: '1 overdue task',
    );
    return 'You have $_temp0 and $today for today. Let\'s clear the overdue ones first.';
  }

  @override
  String briefingOverdue(int overdue) {
    String _temp0 = intl.Intl.pluralLogic(
      overdue,
      locale: localeName,
      other: '$overdue overdue tasks',
      one: '1 overdue task',
    );
    return 'You have $_temp0. I recommend rescheduling or finishing now.';
  }

  @override
  String briefingToday(int today) {
    String _temp0 = intl.Intl.pluralLogic(
      today,
      locale: localeName,
      other: '$today tasks',
      one: '1 task',
    );
    return 'Today you have $_temp0. Good pace — focus on the first one below.';
  }

  @override
  String briefingPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks are',
      one: '1 task is',
    );
    return 'Nothing for today, but $_temp0 pending ahead. How about getting a head start?';
  }

  @override
  String get briefingAllDone =>
      'All done. Clean slate — take the chance to review your notes.';

  @override
  String suggestionFocus(String title, String when) {
    return 'Suggestion: start with \"$title\" ($when). Break it into 10-minute steps if you get stuck.';
  }

  @override
  String get suggestionCreate =>
      'Suggestion: create 3 tasks with a time — e.g. \"Tomorrow 9am gym #health\".';

  @override
  String get whenNoTime => 'no time set';

  @override
  String get whenOverdue => 'overdue';

  @override
  String whenToday(String time) {
    return 'today at $time';
  }

  @override
  String get whenTomorrow => 'tomorrow';

  @override
  String whenInDays(int days) {
    return 'in $days days';
  }

  @override
  String get stepsTravel =>
      'Set dates and budget|Book transport and lodging|Make a packing checklist|Confirm documents';

  @override
  String get stepsStudy =>
      'Split material into 3 blocks|Study block 1 (25 min focus)|Review with summaries|Do practice questions/exercises';

  @override
  String get stepsClean =>
      'Pick 1 room|Sort what goes / stays|Clean for 15 min|Put away and photograph the result';

  @override
  String get stepsProject =>
      'Define the goal in 1 sentence|Draft the structure|Fill in the content|Review and send';

  @override
  String get stepsWorkout =>
      'Get clothes + water ready|Warm up 5 min|Main workout 20 min|Stretch and log it';

  @override
  String get stepsBill =>
      'Check amount and due date|Pay in the app/bank|Save the receipt';

  @override
  String get stepsGeneric =>
      'Define the first 5-minute step|Do it without interruption|Review and mark as done';

  @override
  String slotToday(String time) {
    return 'Today at $time looks free';
  }

  @override
  String get slotTomorrow => 'Tomorrow at 09:00 looks ideal';

  @override
  String get priorityUrgent => 'Urgent';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityNormal => 'Normal';

  @override
  String get priority => 'Priority';

  @override
  String get overdue => 'Overdue';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get noDateGroup => 'No date';

  @override
  String get agenda => 'Schedule';

  @override
  String get agendaFreeTitle => 'Nothing scheduled here';

  @override
  String agendaFreeBody(String tip) {
    return 'Nothing in the next 14 days.\n$tip.';
  }

  @override
  String agendaCount(int count) {
    return '$count on the schedule';
  }

  @override
  String get focus => 'Focus';

  @override
  String get focusDone => 'Focus complete! Time for a break ☕';

  @override
  String get breakDone => 'Break over. Ready for the next cycle?';

  @override
  String get breakLabel => 'BREAK';

  @override
  String focusCycles(int cycles) {
    String _temp0 = intl.Intl.pluralLogic(
      cycles,
      locale: localeName,
      other: '$cycles cycles',
      one: '1 cycle',
    );
    return 'FOCUS • $_temp0';
  }

  @override
  String get breakTip => 'Breathe, stretch, drink water.';

  @override
  String get focusTip => 'AI tip: 1 task, phone away, 25 straight minutes.';

  @override
  String get pause => 'Pause';

  @override
  String get start => 'Start';

  @override
  String get reset => 'Reset';

  @override
  String taskCreatedByAi(String title, int steps) {
    String _temp0 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps steps',
      one: '1 step',
    );
    return 'Created: \"$title\" • $_temp0 suggested by AI';
  }

  @override
  String errorSaving(String error) {
    return 'Error saving: $error';
  }

  @override
  String errorRemoving(String error) {
    return 'Error removing: $error';
  }

  @override
  String errorDeleting(String error) {
    return 'Error deleting: $error';
  }

  @override
  String errorUpdatingTask(String error) {
    return 'Error updating task: $error';
  }

  @override
  String get notificationChannelName => 'Task Reminders';

  @override
  String get notificationChannelDesc => 'Alerts for scheduled tasks';

  @override
  String get updateFailed => 'Update failed. Please try again.';

  @override
  String get searchTasksHint => 'Search tasks or #project…';

  @override
  String get filterAll => 'All';

  @override
  String get filterMyDay => 'My Day';

  @override
  String get filterUpcoming => 'Upcoming';

  @override
  String get filterDone => 'Done';

  @override
  String get emptyDone =>
      'Nothing completed yet — finish the first one and come back.';

  @override
  String get emptyTasks =>
      'No tasks here.\nTap the button below to add one using natural language.';

  @override
  String get completedLabel => 'Completed';

  @override
  String get markAsCompleted => 'Mark as completed';

  @override
  String get projectOptional => 'Project (optional)';

  @override
  String get projectHint => '#project — home, work…';

  @override
  String get aiSuggestedSteps => 'Steps suggested by the local AI';

  @override
  String get signInFailed => 'Could not sign in. Please try again.';

  @override
  String get loginToday => 'Today';

  @override
  String get loginSample1 => 'Pay electricity bill';

  @override
  String get loginSample2 => 'Meeting 9am';

  @override
  String get loginSample3 => 'Gym 6pm';

  @override
  String get loginProgress => '2 of 3 completed';

  @override
  String get loginBadgeTime => 'Mon 9:00';

  @override
  String get loginBadgeMeeting => 'Meeting';

  @override
  String get loginBadgeReminder => 'Reminder';

  @override
  String get loginBadgeGym => 'Gym 6pm';

  @override
  String get welcomeBack => 'Welcome back 👋';

  @override
  String get signInToSee => 'Sign in to see your tasks for today.';

  @override
  String get notesTitle => 'Notes';

  @override
  String get searchNotesHint => 'Search notes…';

  @override
  String noNotesFor(String query) {
    return 'No notes for \"$query\".';
  }

  @override
  String get createNote => 'Create note';

  @override
  String get tryAgain => 'Try again';

  @override
  String errorDeletingNote(String error) {
    return 'Error deleting note: $error';
  }

  @override
  String agoDays(int count) {
    return '${count}d ago';
  }

  @override
  String agoHours(int count) {
    return '${count}h ago';
  }

  @override
  String agoMinutes(int count) {
    return '${count}min ago';
  }

  @override
  String get justNow => 'just now';

  @override
  String get saveNoteFailed => 'Failed to save the note. Please try again.';

  @override
  String agoDaysLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0 ago';
  }

  @override
  String agoHoursLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0 ago';
  }

  @override
  String agoMinutesLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0 ago';
  }

  @override
  String lastEdit(String when) {
    return 'Last edited: $when';
  }

  @override
  String get updateTaskFailed => 'Failed to update.';

  @override
  String get supportEmailSubject => '[Tarefas App] Support & Feedback';

  @override
  String get emailOpenFailed =>
      'Could not open the email app. Contact: hendrilmendes2015@gmail.com';

  @override
  String get userFallback => 'User';

  @override
  String get alerts => 'Alerts';

  @override
  String get sendEmail => 'Send email';

  @override
  String get contactDeveloper => 'Talk to the developer';

  @override
  String steps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String get tabAgenda => 'Schedule';

  @override
  String get assistantBadge => 'LOCAL ASSISTANT';

  @override
  String get focusNow => 'FOCUS NOW';

  @override
  String get pomodoro => 'Pomodoro';

  @override
  String get quickAddEmpty =>
      'Type the task — e.g. Tomorrow 3pm pay bill #home';

  @override
  String get quickAddTitle => 'New smart task';

  @override
  String get quickAddHint => 'E.g. Monday 9am meeting #work !p1';

  @override
  String get quickAddTip =>
      'Tip: use \"tomorrow 3pm\", \"#project\", \"!p1\" and the AI figures it out.';

  @override
  String get noDateSuggestToday => 'No date — suggest today';

  @override
  String suggestedSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suggested steps',
      one: '1 suggested step',
    );
    return '$_temp0';
  }

  @override
  String get priorityColon => 'Priority:';

  @override
  String get releaseNotesEmpty => 'No release notes found for this version.';

  @override
  String releaseNotesError(int code) {
    return 'Error loading release notes. Code: $code';
  }

  @override
  String get releaseNotesConnection =>
      'Error loading. Check your internet connection.';

  @override
  String get language => 'Language';

  @override
  String get languageSub => 'Choose the app language';

  @override
  String get languageAuto => 'Automatic (system)';

  @override
  String get stepsShopping =>
      'List priority items|Check pantry and fridge|Set maximum budget|Go to the supermarket or market';

  @override
  String get stepsMeeting =>
      'Define agenda and goal|Gather links and presentations|Send invite/reminder to attendees|Log minutes and action items';

  @override
  String get stepsCoding =>
      'Understand requirement and edge cases|Create branch and write code|Test locally for error scenarios|Open PR and request review';

  @override
  String get stepsFinance =>
      'Review bank statement|Categorize income and expenses|Spot unnecessary expenses|Update spreadsheet or finance app';

  @override
  String get stepsHealth =>
      'Schedule appointment or exam|Gather past test results|Write down questions for doctor|Confirm time and route';

  @override
  String get noteTotalDetected => 'Detected total:';

  @override
  String noteValuesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count values',
      one: '1 value',
    );
    return '$_temp0';
  }

  @override
  String get insertTotalInNote => 'Insert total into note';
}
