// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PassTheBook';

  @override
  String get tabReading => 'Reading';

  @override
  String get tabLibrary => 'Library';

  @override
  String get tabLoans => 'Loans';

  @override
  String get tabGroups => 'Groups';

  @override
  String get tooltipBulletin => 'Literary Bulletin';

  @override
  String get tooltipBookshelf => 'Virtual Bookshelf';

  @override
  String get tooltipNotifications => 'Notifications';

  @override
  String get tooltipProfile => 'Profile';

  @override
  String get tooltipSettings => 'Settings';

  @override
  String get tooltipEdit => 'Edit';

  @override
  String get tooltipSave => 'Save';

  @override
  String get tooltipLoanHistory => 'Loan history';

  @override
  String get tooltipSortBooks => 'Sort books';

  @override
  String get tooltipViewList => 'View list';

  @override
  String get tooltipViewGrid => 'View grid';

  @override
  String get tooltipRefreshCovers => 'Refresh covers';

  @override
  String get tooltipExportLibrary => 'Export library';

  @override
  String get tooltipRead => 'Read';

  @override
  String get addBook => 'Add book';

  @override
  String get debugResetPin => 'Debug: reset PIN';

  @override
  String get snackBookAdded => 'Book added to your library.';

  @override
  String get snackBookUpdated => 'Book updated successfully.';

  @override
  String get snackBookDeleted => 'Book deleted.';

  @override
  String get snackPinCleared => 'PIN cleared (debug only).';

  @override
  String get residenceRequired => 'Residence required';

  @override
  String get residenceRequiredMessage =>
      'To receive literary bulletins from your area, please fill in your place of residence in your profile.';

  @override
  String get notNow => 'Not now';

  @override
  String get goToProfile => 'Go to Profile';

  @override
  String noBulletinPlaceholder(String province) {
    return 'No notable literary events have been recorded in the province of $province this month. Subscribe to our notifications to stay updated!';
  }

  @override
  String errorLoadingBulletin(String error) {
    return 'Error loading bulletin: $error';
  }

  @override
  String get readingHeader => 'Reading';

  @override
  String get activityHeader => 'Activity';

  @override
  String get chartRhythm => 'Rhythm';

  @override
  String get chartCalendar => 'Calendar';

  @override
  String get noActiveReading => 'No active readings';

  @override
  String get goToLibrary => 'Go to your library to start';

  @override
  String get statusPaused => 'Paused';

  @override
  String get readingNow => 'Reading now';

  @override
  String get libraryHeader => 'Library';

  @override
  String get tabMyBooks => 'My books';

  @override
  String get tabBorrowedBooks => 'Borrowed';

  @override
  String get emptyMyBooksMessage => 'Add your books to manage them here.';

  @override
  String get emptyBorrowedBooksMessage =>
      'Books borrowed from friends will appear here, whether through the app or in person.';

  @override
  String get noFilterResults => 'No matches with current filters.';

  @override
  String get sortTitleAZ => 'Title (A-Z)';

  @override
  String get sortTitleZA => 'Title (Z-A)';

  @override
  String get sortAuthorAZ => 'Author (A-Z)';

  @override
  String get sortAuthorZA => 'Author (Z-A)';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortOldest => 'Oldest';

  @override
  String get genreFilter => 'Genre';

  @override
  String get allGenres => 'All genres';

  @override
  String get loansHeader => 'Loans';

  @override
  String get loan => 'loan';

  @override
  String get loans => 'loans';

  @override
  String get requests => 'requests';

  @override
  String incomingRequests(int count) {
    return 'Incoming Requests ($count)';
  }

  @override
  String outgoingRequests(int count) {
    return 'Outgoing Requests ($count)';
  }

  @override
  String get lentByYou => 'Lent by you';

  @override
  String get borrowedFromOthers => 'Borrowed';

  @override
  String get recentLoans => 'Recent';

  @override
  String get manualLoan => 'Manual Loan';

  @override
  String loanRequestedBy(String name) {
    return 'Requested by $name';
  }

  @override
  String lentByWithName(String name) {
    return 'De $name';
  }

  @override
  String loanRequestedTo(String name) {
    return 'Requested to $name';
  }

  @override
  String get reject => 'Reject';

  @override
  String get accept => 'Accept';

  @override
  String get cancelRequest => 'Cancel request';

  @override
  String get acceptLoanTitle => 'Accept Loan';

  @override
  String get selectDueDate => 'Select a due date:';

  @override
  String get indefinite => 'Indefinite';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get youLent => 'You lent';

  @override
  String get theyLentYou => 'They lent you';

  @override
  String get bookFallback => 'Book';

  @override
  String get someoneFallback => 'Someone';

  @override
  String get ownerFallback => 'Owner';

  @override
  String get book => 'book';

  @override
  String booksCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books',
      one: '1 book',
    );
    return '$_temp0';
  }

  @override
  String get fromLabel => 'From:';

  @override
  String get toLabel => 'To:';

  @override
  String get lendBookManually => 'Lend a book manually';

  @override
  String get lendBookManuallyDesc =>
      'Register a loan from your library to someone without the app';

  @override
  String get registerReceivedBook => 'Register received book';

  @override
  String get registerReceivedBookDesc => 'Register a book someone lent you';

  @override
  String get loanStatusRequested => 'Requested';

  @override
  String get loanStatusActive => 'Active';

  @override
  String get loanStatusReturned => 'Returned';

  @override
  String get loanStatusCancelled => 'Cancelled';

  @override
  String get loanStatusRejected => 'Rejected';

  @override
  String get loanStatusCompleted => 'Completed';

  @override
  String get loanStatusExpired => 'Expired';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEditTitle => 'Edit Profile';

  @override
  String get statsBooks => 'Books';

  @override
  String get statsRead => 'Read';

  @override
  String get statsReading => 'Reading';

  @override
  String get aboutMe => 'About me';

  @override
  String get favoriteBook => 'Favorite book';

  @override
  String get favoriteGenre => 'Favorite genre';

  @override
  String get locationLabel => 'Location';

  @override
  String get contactLabel => 'Contact';

  @override
  String get biographyHeader => 'Biography';

  @override
  String get quickAccess => 'Quick access';

  @override
  String get myReadBooks => 'My read books';

  @override
  String get wishlist => 'Wishlist';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get nameFromRegistration => 'Name (from registration)';

  @override
  String get emailLabel => 'Email';

  @override
  String get residenceLabel => 'Place of residence (Province)';

  @override
  String get favoriteBookLabel => 'Favorite book';

  @override
  String get favoriteGenreLabel => 'Favorite genre';

  @override
  String get biographyNotesLabel => 'Biography / Notes';

  @override
  String get selectValidProvince =>
      'Please select a valid province from the list';

  @override
  String get settingsLibrary => 'Library';

  @override
  String get settingsLibraryDesc => 'Import or export your book library.';

  @override
  String get exportLibrary => 'Export library';

  @override
  String get exportLibraryDesc => 'Save your book list as CSV, JSON or PDF';

  @override
  String get exportLoanHistory => 'Export loan history';

  @override
  String get exportLoanHistoryDesc => 'Generate a report of your loans (CSV)';

  @override
  String get importBooks => 'Import books';

  @override
  String get importBooksDesc => 'Import books from a CSV or JSON file';

  @override
  String get settingsStorage => 'Storage';

  @override
  String get deleteAllCovers => 'Delete all covers';

  @override
  String get deleteAllCoversDesc =>
      'Free up space by deleting downloaded cover images.';

  @override
  String get resetLocalDatabase => 'Reset local database';

  @override
  String get resetLocalDatabaseDesc =>
      'Delete all local data and start from scratch.';

  @override
  String get settingsBackup => 'Backups';

  @override
  String get settingsSecurity => 'Security settings';

  @override
  String get settingsSecurityDesc =>
      'Manage your PIN and control automatic lock on inactivity.';

  @override
  String get changePin => 'Change PIN';

  @override
  String get changePinDesc => 'Redefine the access code.';

  @override
  String get deletePinAndSwitchUser => 'Delete PIN and switch user';

  @override
  String get deletePinAndSwitchUserDesc =>
      'Go back to setup to configure another account.';

  @override
  String get deletePinConfirmTitle => 'Delete PIN and sign out?';

  @override
  String get deletePinConfirmMessage =>
      'ALL local data (books, groups, loans) will be deleted and you will need to sign in or set up a new user.';

  @override
  String get deletePinTip =>
      '💡 Tip: Export your library before continuing. If you have automatic backups, look for them in Downloads/BookSharing/backups.';

  @override
  String get deleteAll => 'Delete all';

  @override
  String get dataDeleted =>
      'Data deleted. Restart the app to set up a new user.';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageDesc => 'Select the language for the app.';

  @override
  String get languageSystem => 'System';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsExternalIntegrations => 'External integrations';

  @override
  String get settingsMoreComingSoon => 'More settings coming soon';

  @override
  String get settingsMoreComingSoonDesc =>
      'Soon you\'ll be able to manage backups, sync and preferences.';

  @override
  String get settingsOpenLibraryCredit =>
      'Bibliographic data provided by Open Library (Internet Archive). Content under ODC-By license.';

  @override
  String get donationTitle => 'Buy me a coffee';

  @override
  String get donationMessage =>
      'If you find this app useful, you can support its development with a donation.';

  @override
  String get donationButton => 'Buy me a coffee';

  @override
  String get donationLinkInvalid => 'The donation link is not valid.';

  @override
  String get donationLinkError => 'Could not open the donation link.';

  @override
  String donationLinkOpenError(String error) {
    return 'Error opening link: $error';
  }

  @override
  String get syncStatus => 'Sync status';

  @override
  String get syncingWithSupabase => 'Syncing with Supabase...';

  @override
  String lastSync(String date) {
    return 'Last sync: $date';
  }

  @override
  String get notSyncedYet => 'Not yet synced with Supabase.';

  @override
  String get syncErrorRecent => 'Recent sync errors found';

  @override
  String get syncLastError => 'Last sync error';

  @override
  String get pendingChanges => 'There are pending changes to sync.';

  @override
  String get manualSync => 'Manual sync';

  @override
  String get manualSyncDesc =>
      'Force upload and download of books, loans and clubs with Supabase. This normally happens automatically in the background.';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncComplete => 'Sync completed.';

  @override
  String syncError(String error) {
    return 'Sync error: $error';
  }

  @override
  String get resetDatabaseTitle => '⚠️ Reset local database';

  @override
  String get resetDatabaseWarning => 'This will delete ALL local data:';

  @override
  String get resetDatabaseItem1 => '• Registered books';

  @override
  String get resetDatabaseItem2 => '• Groups and memberships';

  @override
  String get resetDatabaseItem3 => '• Loans and notifications';

  @override
  String get resetDatabaseItem4 => '• Local settings';

  @override
  String get resetDatabaseCloudNote =>
      'Cloud data (Supabase) will NOT be deleted.';

  @override
  String get resetDatabaseRestartNote =>
      'After reset, the app will restart automatically.';

  @override
  String get resetAll => 'Reset all';

  @override
  String get resettingDatabase => 'Resetting database...';

  @override
  String get databaseResetSuccess => 'Database reset. Restarting app...';

  @override
  String databaseResetError(String error) {
    return 'Error resetting database: $error';
  }

  @override
  String get deleteCoversConfirmTitle => 'Delete all covers?';

  @override
  String get deleteCoversConfirmMessage =>
      'All downloaded cover images will be deleted. You can re-download them manually from the library.';

  @override
  String get delete => 'Delete';

  @override
  String coversDeleted(int count) {
    return '$count covers deleted.';
  }

  @override
  String coversDeleteError(String error) {
    return 'Error deleting covers: $error';
  }

  @override
  String get googleBooksApi => 'Google Books API';

  @override
  String get googleBooksApiConfigured =>
      'API key configured. You can search books on Google Books.';

  @override
  String get googleBooksApiNotConfigured =>
      'Configure an API key to search books on Google Books.';

  @override
  String get changeApiKey => 'Change API key';

  @override
  String get configureApiKey => 'Configure API key';

  @override
  String get removeLabel => 'Remove';

  @override
  String get howToGetApiKey => 'How to get an API key?';

  @override
  String get apiKeyInstructions =>
      '1. Go to Google Cloud Console\n2. Create a new project or select an existing one\n3. Enable the \"Books API\"\n4. Create credentials of type \"API key\"\n5. Copy the key and paste it here';

  @override
  String get configureGoogleBooksApiKey => 'Configure Google Books API key';

  @override
  String get apiKeyInputHint =>
      'Enter your Google Books API key to search for books.';

  @override
  String get apiKeySaved => 'API key saved successfully.';

  @override
  String apiKeySaveError(String error) {
    return 'Error saving API key: $error';
  }

  @override
  String get deleteApiKeyConfirmTitle => 'Delete Google Books API key?';

  @override
  String get deleteApiKeyConfirmMessage =>
      'The saved API key will be deleted. Book search on Google Books will stop working until you configure a new key.';

  @override
  String get apiKeyDeleted => 'API key deleted.';

  @override
  String apiKeyDeleteError(String error) {
    return 'Error deleting API key: $error';
  }

  @override
  String exportLoansError(String error) {
    return 'Error exporting loans: $error';
  }

  @override
  String get activeSessionRequired => 'You must have an active session.';

  @override
  String get themeSystem => 'Use system theme';

  @override
  String get themeLight => 'Light mode';

  @override
  String get themeDark => 'Dark mode';

  @override
  String get themeLoadError => 'Could not load theme preference.';

  @override
  String get retry => 'Retry';

  @override
  String get genreFantasy => 'Fantasy';

  @override
  String get genreScienceFiction => 'Science Fiction';

  @override
  String get genreHorror => 'Horror';

  @override
  String get genreThrillerSuspense => 'Thriller / Suspense';

  @override
  String get genreCrimeMystery => 'Crime / Mystery';

  @override
  String get genreRomance => 'Romance';

  @override
  String get genreHistorical => 'Historical';

  @override
  String get genreLiteraryFiction => 'Literary Fiction';

  @override
  String get genreNonFiction => 'Non-Fiction';

  @override
  String get genreBiographyMemoir => 'Biography / Memoir';

  @override
  String get genreEssay => 'Essay';

  @override
  String get genrePhilosophy => 'Philosophy';

  @override
  String get genrePoetry => 'Poetry';

  @override
  String get genreComicsGraphicNovel => 'Comics / Graphic Novel';

  @override
  String get genreYoungAdult => 'Young Adult (YA)';

  @override
  String get genreChildren => 'Children';

  @override
  String get genreTechnicalEducational => 'Technical / Educational';

  @override
  String get genreSelfHelp => 'Self-Help';

  @override
  String get genrePoliticsSociety => 'Politics / Society';

  @override
  String get genreReligionSpirituality => 'Religion / Spirituality';

  @override
  String get genreHumor => 'Humor';

  @override
  String get genreAdventure => 'Adventure';

  @override
  String get genreDystopian => 'Dystopian';

  @override
  String get genreClassic => 'Classic';

  @override
  String get evocEmptyLibraryTitle => 'Your library awaits in silence';

  @override
  String get evocEmptyLibraryMessage =>
      'The shelves await their first inhabitants. Every great collection begins with a single book.';

  @override
  String get evocEmptyLibraryAction => 'Add first book';

  @override
  String get evocEmptySharedLibraryTitle => 'The collective archive is empty';

  @override
  String get evocEmptySharedLibraryMessage =>
      'There are no shared books in this reading circle yet. Be the first to contribute to the shared knowledge.';

  @override
  String get evocEmptyLoansTitle => 'No stories in transit';

  @override
  String get evocEmptyLoansMessage =>
      'The books rest on their shelves. Start a new journey by sharing a read.';

  @override
  String get evocEmptyLoansAction => 'Register loan';

  @override
  String get evocEmptyPendingLoansTitle => 'No pending requests';

  @override
  String get evocEmptyPendingLoansMessage =>
      'The request box is empty. No reader awaits at the moment.';

  @override
  String get evocEmptyGroupsTitle => 'You\'re not part of any circle yet';

  @override
  String get evocEmptyGroupsMessage =>
      'Reading circles are communities where stories flow. Join one or create your own.';

  @override
  String get evocEmptyGroupsAction => 'Create circle';

  @override
  String get evocEmptyReviewsTitle => 'No reviews yet';

  @override
  String get evocEmptyReviewsMessage =>
      'This book awaits its first impression. What did you think of its story?';

  @override
  String get evocEmptyReviewsAction => 'Write first review';

  @override
  String get evocWelcomeTitle => 'Welcome to your personal library';

  @override
  String get evocWelcomeMessage =>
      'A place where stories find a home and travel between readers.';

  @override
  String get evocEnteringArchive => 'Entering the archive...';

  @override
  String get evocLoadingBooks => 'Gathering the volumes...';

  @override
  String get evocSyncingLibrary => 'Syncing the catalog...';

  @override
  String evocArchiveButton(String groupName) {
    return 'The Great Archive of $groupName';
  }

  @override
  String get evocArchiveButtonShort => 'The Great Archive';

  @override
  String get evocLoanConfirmed => 'The book has begun its journey';

  @override
  String get evocLoanReturned => 'The book has returned home';

  @override
  String get evocBookAdded => 'A new volume joins your collection';

  @override
  String get evocBookRemoved => 'The book has been removed from the catalog';

  @override
  String get evocBookNotFound => 'This volume seems to have gone missing';

  @override
  String get evocConnectionError =>
      'Cannot reach the remote archive at this time';

  @override
  String get evocSyncError => 'There was a problem syncing the catalog';

  @override
  String get evocReadStatus => 'Read';

  @override
  String get evocUnreadStatus => 'To read';

  @override
  String get evocReadingStatus => 'Reading';

  @override
  String evocLoanRequest(String requester, String bookTitle) {
    return '$requester requests \"$bookTitle\" from your library';
  }

  @override
  String evocLoanAccepted(String bookTitle) {
    return 'Your request for \"$bookTitle\" has been accepted';
  }

  @override
  String evocLoanReturnReminder(String bookTitle, int daysLeft) {
    String _temp0 = intl.Intl.pluralLogic(
      daysLeft,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '\"$bookTitle\" must be returned in $daysLeft $_temp0';
  }

  @override
  String evocLoanOverdue(String bookTitle) {
    return '\"$bookTitle\" has exceeded its loan period';
  }

  @override
  String get readingStatusPending => 'Pending';

  @override
  String get readingStatusReading => 'Reading';

  @override
  String get readingStatusPaused => 'Paused';

  @override
  String get readingStatusFinished => 'Finished';

  @override
  String get readingStatusAbandoned => 'Abandoned';

  @override
  String get readingStatusRereading => 'Rereading';

  @override
  String get bookStatusAvailable => 'Available';

  @override
  String get bookStatusLoaned => 'Loaned';

  @override
  String get bookStatusPrivate => 'Private';

  @override
  String get bookStatusArchived => 'Archived';

  @override
  String get searchBooks => 'Search books...';

  @override
  String get readFilter => 'Read';

  @override
  String get unreadFilter => 'Unread';

  @override
  String get allFilter => 'All';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get error => 'Error';

  @override
  String get errorStateLabel => 'Error';

  @override
  String get loading => 'Loading...';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String errorImporting(Object error) {
    return 'Error importing: $error';
  }

  @override
  String get notificationLoanDueSoonTitle => 'Loan due soon';

  @override
  String get notificationLoanDueSoonBody =>
      'Your loan is due in less than a week.';

  @override
  String notificationLoanDueSoonBodyWithTitle(String title) {
    return 'The loan for \"$title\" is due soon.';
  }

  @override
  String get notificationLoanExpiredTitle => 'Loan expired';

  @override
  String get notificationLoanExpiredBody =>
      'Your loan has reached its deadline.';

  @override
  String notificationLoanExpiredBodyWithTitle(String title) {
    return 'The loan for \"$title\" has expired.';
  }

  @override
  String get notificationLoanRequestTitle => 'New loan request';

  @override
  String notificationLoanRequestFallback(String name) {
    return '$name requested a loan.';
  }

  @override
  String notificationLoanRequestWithTitle(String name, String title) {
    return '$name wants to borrow \"$title\".';
  }

  @override
  String get notificationLoanCancelledTitle => 'Loan request cancelled';

  @override
  String notificationLoanCancelledFallback(String name) {
    return '$name cancelled the loan request.';
  }

  @override
  String notificationLoanCancelledWithTitle(String name, String title) {
    return '$name cancelled the request for \"$title\".';
  }

  @override
  String get notificationLoanRejectedTitle => 'Loan request rejected';

  @override
  String notificationLoanRejectedFallback(String name) {
    return '$name rejected your loan request.';
  }

  @override
  String notificationLoanRejectedWithTitle(String name, String title) {
    return '$name rejected your request for \"$title\".';
  }

  @override
  String get notificationLoanAcceptedTitle => 'Loan accepted';

  @override
  String notificationLoanAcceptedFallback(String name) {
    return '$name accepted your loan request.';
  }

  @override
  String notificationLoanAcceptedWithTitle(String name, String title) {
    return '$name accepted your request for \"$title\".';
  }

  @override
  String get notificationLoanReturnedTitle => 'Loan marked as returned';

  @override
  String notificationLoanReturnedFallback(String name) {
    return '$name marked the loan as returned.';
  }

  @override
  String notificationLoanReturnedWithTitle(String name, String title) {
    return '$name marked \"$title\" as returned.';
  }

  @override
  String get notificationReturnReminderTitle => 'Confirmation pending';

  @override
  String get notificationReturnReminderFallback =>
      'Reminder to confirm return.';

  @override
  String notificationReturnReminderWithTitle(String title) {
    return 'Reminder: Please confirm the return of \"$title\".';
  }

  @override
  String get loanManualRegistered => 'Manual loan registered.';

  @override
  String get loanExternalRegistered => 'External loan registered.';

  @override
  String get loanRequestSent => 'Request sent.';

  @override
  String get loanRequestCancelled => 'Request cancelled.';

  @override
  String get loanRequestRejected => 'Request rejected.';

  @override
  String get loanRequestAccepted => 'Loan accepted.';

  @override
  String get loanMarkedReturned => 'Loan marked as returned.';

  @override
  String get loanMarkedExpired => 'Loan marked as expired.';

  @override
  String get loanReturnConfirmed => 'Return confirmed.';

  @override
  String get loanReminderSent => 'Reminder sent.';

  @override
  String get errorLoanDueDatePast => 'Due date cannot be in the past.';

  @override
  String get errorLoanCancelledByOther =>
      'The user cancelled the request before you could accept it.';

  @override
  String get errorLoanAlreadyActive =>
      'This book is already on loan to someone else.';

  @override
  String get errorLoanInvalidState =>
      'The request is no longer valid (maybe it was already accepted or rejected).';

  @override
  String get groupCreated => 'Group created.';

  @override
  String get groupUpdated => 'Group updated.';

  @override
  String get groupDeleted => 'Group deleted.';

  @override
  String get ownershipTransferred => 'Ownership transferred.';

  @override
  String get memberAdded => 'Member added.';

  @override
  String get roleUpdated => 'Role updated.';

  @override
  String get memberRemoved => 'Member removed.';

  @override
  String get invitationCreated => 'Invitation created.';

  @override
  String get invitationCancelled => 'Invitation cancelled.';

  @override
  String get invitationAccepted => 'Invitation accepted.';

  @override
  String get invitationUpdated => 'Invitation updated.';

  @override
  String get joinedGroup => 'Joined the group.';

  @override
  String notificationGroupUpdatedTitle(String name) {
    return 'Group \"$name\" updated';
  }

  @override
  String get notificationGroupUpdatedMessage =>
      'Changes have been made to the group details.';

  @override
  String get notificationGroupDeletedTitle => 'Group deleted';

  @override
  String notificationGroupDeletedMessage(String name) {
    return 'The group \"$name\" has been dissolved.';
  }

  @override
  String notificationGroupMemberJoinedTitle(String name) {
    return 'New member in \"$name\"';
  }

  @override
  String notificationGroupMemberJoinedMessage(String name) {
    return '$name joined the group.';
  }

  @override
  String notificationGroupMemberLeftTitle(String name) {
    return 'Member left \"$name\"';
  }

  @override
  String notificationGroupMemberLeftMessage(String name) {
    return '$name left the group.';
  }

  @override
  String notificationGroupMemberJoinedByCodeMessage(String name) {
    return '$name joined by code.';
  }

  @override
  String userFallback(int id) {
    return 'User $id';
  }

  @override
  String get statusRequested => 'Requested';

  @override
  String get statusRequestedCaption => 'Request pending approval';

  @override
  String get statusOnLoan => 'On loan';

  @override
  String get statusOnLoanCaption => 'Active loan';

  @override
  String get statusAvailable => 'Available';

  @override
  String get statusUnavailable => 'Unavailable';

  @override
  String get tooltipViewMembers => 'View members';

  @override
  String get tooltipSortBy => 'Sort by';

  @override
  String get filterHideRead => 'Hide read';

  @override
  String get filterIncludeUnavailable => 'Include unavailable';

  @override
  String get errorLoadingLibrary => 'We couldn\'t load your library.';

  @override
  String get errorLoadingSharedBooksGeneric =>
      'We couldn\'t load shared books.';

  @override
  String get emptySearchTitle => 'No results for your search';

  @override
  String get emptySearchMessage =>
      'Check the entered term or reset filters to see more books.';

  @override
  String get actionClearSearch => 'Clear search';

  @override
  String get emptyMemberBooksTitle => 'No books from this member';

  @override
  String get emptyMemberBooksMessage =>
      'Try another person or show all available books again.';

  @override
  String get actionRemoveFilter => 'Remove filter';

  @override
  String get emptyDiscoverTitle => 'No books to discover yet';

  @override
  String get emptyDiscoverMessage =>
      'When other members share compatible copies, you will see them listed here.';

  @override
  String get actionUpdateList => 'Update list';

  @override
  String get bookNoTitle => 'Untitled book';

  @override
  String bookPages(int count) {
    return '$count pages';
  }

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String reviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
    );
    return '$_temp0';
  }

  @override
  String bookOwner(String name) {
    return 'Owner: $name';
  }

  @override
  String get bookFormatPhysical => 'Physical';

  @override
  String get bookFormatDigital => 'Digital';

  @override
  String get bookNoDescription => 'This book has no description added.';

  @override
  String get actionsTitle => 'Actions';

  @override
  String reservedBy(String name) {
    return 'Reserved by $name';
  }

  @override
  String get loanPendingApproval => 'pending approval';

  @override
  String get loanInProgress => 'in progress';

  @override
  String loanStatusMessage(String status) {
    return 'The loan is $status. You can request it when it becomes available again.';
  }

  @override
  String get errorLocalSessionRequired => 'Local login required.';

  @override
  String get errorLocalSessionMessage =>
      'Only locally registered users can request loans.';

  @override
  String get pendingRequestTitle => 'Pending request';

  @override
  String pendingRequestFrom(String name) {
    return 'You have a request from $name for this book.';
  }

  @override
  String get actionAcceptRequest => 'Accept request';

  @override
  String get actionRejectRequest => 'Reject';

  @override
  String get actionBorrow => 'Borrow';

  @override
  String get actionAddToLibrary => 'Add to library';

  @override
  String get actionCancelRequest => 'Cancel request';

  @override
  String alreadyRequestedMessage(String status) {
    return 'You already sent a request for this book and it is $status.';
  }

  @override
  String get bookNotAvailableMessage =>
      'This book is not available at the moment.';

  @override
  String get errorLoadingBook => 'We couldn\'t load this book.';

  @override
  String get warningSelectOwner => 'Please select an owner first.';

  @override
  String ownerSelectorLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return 'Available through $_temp0:';
  }

  @override
  String get me => 'Me (owner)';

  @override
  String get availableNow => 'Available now';

  @override
  String get notInLibrary => 'Not in your library';

  @override
  String get opinar => 'Review';

  @override
  String get edit => 'Edit';

  @override
  String get dialogCancelRequestTitle => 'Cancel request?';

  @override
  String get dialogCancelRequestMessage =>
      'Are you sure you want to cancel this loan request?';

  @override
  String get dialogRejectRequestTitle => 'Reject request?';

  @override
  String get dialogRejectRequestMessage =>
      'Are you sure you want to reject this loan request?';

  @override
  String get dialogAddToLibraryTitle => 'Add to library?';

  @override
  String get dialogAddToLibraryMessage =>
      'Are you sure you want to add this book to your personal library?';

  @override
  String get errorOriginalMetadataNotFound =>
      'Original book metadata not found';

  @override
  String bookAddedToLibrary(String title) {
    return '\"$title\" added to your library';
  }

  @override
  String get errorAlreadyInLibrary =>
      'You already have this book in your library';

  @override
  String errorAddingToLibrary(String error) {
    return 'Error adding to library: $error';
  }

  @override
  String get userUnknown => 'Unknown user';

  @override
  String get selectOwnerTitle => 'Who do you want to ask?';

  @override
  String get addedFromGroup => 'Added from a group';

  @override
  String get actionRequestLoan => 'Request loan';

  @override
  String get unknown => 'Unknown';

  @override
  String groupLibrarian(String name) {
    return 'Master Reader: $name (Owner)';
  }

  @override
  String lastUpdate(String date) {
    return 'Last update: $date';
  }

  @override
  String get tooltipSyncGroup => 'Sync group';

  @override
  String get actionEditGroup => 'Edit group';

  @override
  String get actionManageMembers => 'Manage members';

  @override
  String get actionManageInvitations => 'Manage invitations';

  @override
  String get actionViewMembers => 'View members';

  @override
  String get actionTransferOwnership => 'Transfer ownership';

  @override
  String get actionDeleteGroup => 'Delete group';

  @override
  String get actionLeaveGroup => 'Leave group';

  @override
  String get tooltipGroupActions => 'Group actions';

  @override
  String get dialogTransferOwnershipTitle => 'Transfer ownership?';

  @override
  String dialogTransferOwnershipMessage(String name) {
    return 'Are you sure you want to transfer group ownership to $name?';
  }

  @override
  String get dialogDeleteGroupTitle => 'Delete group?';

  @override
  String dialogDeleteGroupMessage(String name) {
    return 'Are you sure you want to delete the group \"$name\"? This action cannot be undone.';
  }

  @override
  String get dialogLeaveGroupTitle => 'Leave group?';

  @override
  String dialogLeaveGroupMessage(String name) {
    return 'Are you sure you want to leave the group \"$name\"?';
  }

  @override
  String get errorUnexpected => 'An unexpected error occurred';

  @override
  String get successGroupDeleted => 'Group successfully deleted';

  @override
  String get successGroupLeft => 'You have left the group';

  @override
  String successOwnershipTransferred(String name) {
    return 'Ownership transferred to $name';
  }

  @override
  String get successGroupUpdated => 'Group updated successfully';

  @override
  String errorUpdatingGroup(String error) {
    return 'Error updating group: $error';
  }

  @override
  String get errorNoOtherMembers => 'There are no other members to transfer to';

  @override
  String errorTransferringOwnership(String error) {
    return 'Error transferring ownership: $error';
  }

  @override
  String errorDeletingGroup(String error) {
    return 'Error deleting group: $error';
  }

  @override
  String errorLeavingGroup(String error) {
    return 'Error leaving group: $error';
  }

  @override
  String get actionTransfer => 'Transfer';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionLeave => 'Leave';

  @override
  String get statMembers => 'Members';

  @override
  String get statBooks => 'Books';

  @override
  String get statAvailable => 'Available';

  @override
  String get contributionTitle => 'Your contribution';

  @override
  String contributionMessage(int count, int activeLoans) {
    return 'You have shared $count books and $activeLoans are on loan.';
  }

  @override
  String get actionCreateInvitation => 'Create invitation';

  @override
  String get noPendingInvitations => 'No pending invitations';

  @override
  String invitationCodeLabel(String code) {
    return 'Code: $code';
  }

  @override
  String invitationExpiresLabel(String date) {
    return 'Expires: $date';
  }

  @override
  String get successInvitationCreated => 'Invitation created successfully';

  @override
  String errorCreatingInvitation(String error) {
    return 'Error creating invitation: $error';
  }

  @override
  String shareInvitationMessage(String code) {
    return 'I\'m sending you this invitation to join my readers\' group: $code';
  }

  @override
  String get shareInvitationSubject => 'Readers\' group invitation';

  @override
  String errorSharing(String error) {
    return 'Error sharing: $error';
  }

  @override
  String get dialogCancelInvitationTitle => 'Cancel invitation';

  @override
  String get dialogCancelInvitationMessage =>
      'Are you sure you want to cancel this invitation?';

  @override
  String get actionCancelInvitationConfirm => 'Yes, cancel';

  @override
  String get successInvitationCancelled => 'Invitation cancelled';

  @override
  String errorCancellingInvitation(String error) {
    return 'Error cancelling invitation: $error';
  }

  @override
  String get noLabel => 'No';

  @override
  String get yesLabel => 'Yes';

  @override
  String get invitationsHeader => 'Invitations';

  @override
  String get starMemberTooltip => 'Star Member (Maximum activity)';

  @override
  String get badgeBibliophile => 'Bibliophile';

  @override
  String get badgeCurator => 'Curator';

  @override
  String get badgeLibrarian => 'Librarian';

  @override
  String get badgeActiveReader => 'Active Reader';

  @override
  String get badgeGenerous => 'Generous';

  @override
  String get actionMakeAdmin => 'Make admin';

  @override
  String get actionMakeMember => 'Make member';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleMember => 'Member';

  @override
  String get successMemberRemoved => 'Member removed';

  @override
  String get successRoleUpdated => 'Role updated';

  @override
  String get selectNewOwnerTitle => 'Select new owner';

  @override
  String excludedByFilter(int count, int passing) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books excluded',
      one: '1 book excluded',
    );
    return '$_temp0 by genre filter · $passing visible';
  }

  @override
  String get actionCreateGroup => 'Create group';

  @override
  String get actionJoinByCode => 'Join by code';

  @override
  String get syncGroupsTitle => 'Sync your groups';

  @override
  String get syncGroupsMessage =>
      'Connect with Supabase to bring your communities, members, and shared books.';

  @override
  String get actionSyncNow => 'Sync now';

  @override
  String get errorLoadingGroups => 'We couldn\'t load your groups.';

  @override
  String get actionRetrySync => 'Retry synchronization';

  @override
  String errorCreatingGroup(String error) {
    return 'Couldn\'t create group: $error';
  }

  @override
  String get thematicGroupTitle => 'Thematic group';

  @override
  String thematicGroupMessage(String genres) {
    return 'This group has an active genre filter: $genres.\n\nOnly physical books of those genres will be visible in this group.';
  }

  @override
  String get actionGotIt => 'Got it';

  @override
  String errorSyncing(String error) {
    return 'Sync error: $error';
  }

  @override
  String get syncCompleted => 'Synchronization completed.';

  @override
  String get joinGroupTitle => 'Join group';

  @override
  String get groupCodeLabel => 'Group code';

  @override
  String get successJoinedGroup => 'You have joined the group successfully!';

  @override
  String get pleaseEnterCode => 'Please enter a code';

  @override
  String get actionJoin => 'Join';

  @override
  String get errorInvalidCode =>
      'The code is invalid or has expired. Please verify it and try again.';

  @override
  String get coachMarkDiscoverShareTitle => 'Share your books';

  @override
  String get coachMarkDiscoverShareDesc =>
      'Publish copies so your group can request them quickly.';

  @override
  String get coachMarkDiscoverFiltersTitle => 'Filter results';

  @override
  String get coachMarkDiscoverFiltersDesc =>
      'Use these filters to see books from specific groups or owners.';

  @override
  String get coachMarkDetailRequestTitle => 'Request a loan';

  @override
  String get coachMarkDetailRequestDesc =>
      'From here you can request to borrow the book and coordinate delivery.';

  @override
  String get coachMarkGroupInviteTitle => 'Manage invitations';

  @override
  String get coachMarkGroupInviteDesc =>
      'Invite new people or review pending requests for your group.';

  @override
  String get actionNext => 'Next';

  @override
  String get actionDone => 'Done';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionCreateGroupDialog => 'Create group';

  @override
  String get groupNameLabel => 'Group name';

  @override
  String get errorInvalidGroupName => 'Enter a valid name.';

  @override
  String get groupDescriptionLabel => 'Description (optional)';

  @override
  String get allowedGenresLabel => 'Allowed genres';

  @override
  String get optionalLabel => '(optional)';

  @override
  String get genreFilterExplanation =>
      'If you choose genres, only books of those genres will be visible in this group. If none selected, all are shown.';

  @override
  String get genreChangeLaterHint =>
      'You can change genres later from the group menu.';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCreate => 'Create';

  @override
  String get noActiveLoansInGroup => 'You have no active loans in this group.';

  @override
  String get yourLoansHeader => 'Your loans';

  @override
  String errorLoadingLoans(String error) {
    return 'Error loading loans: $error';
  }

  @override
  String get errorIdentifyingBorrower => 'Couldn\'t identify the borrower.';

  @override
  String get successLoanCancelled => 'Request cancelled.';

  @override
  String errorCancellingLoan(String error) {
    return 'Couldn\'t cancel the request: $error';
  }

  @override
  String get errorIdentifyingOwner => 'Couldn\'t identify the owner.';

  @override
  String get successLoanAccepted => 'Loan accepted.';

  @override
  String errorAcceptingLoan(String error) {
    return 'Couldn\'t accept the loan: $error';
  }

  @override
  String get successLoanRejected => 'Request rejected.';

  @override
  String errorRejectingLoan(String error) {
    return 'Couldn\'t reject the request: $error';
  }

  @override
  String get errorIdentifyingActiveUser =>
      'Couldn\'t identify the active user.';

  @override
  String get successLoanReturned => 'Loan marked as returned.';

  @override
  String errorMarkingReturned(String error) {
    return 'Couldn\'t mark as returned: $error';
  }

  @override
  String get errorPreparingRequest =>
      'Couldn\'t prepare the request for this book.';

  @override
  String get successLoanRequested => 'Request sent.';

  @override
  String errorRequestingLoan(String error) {
    return 'Couldn\'t send the request: $error';
  }

  @override
  String get bookLabel => 'Book';

  @override
  String get noDueDate => 'No due date';

  @override
  String loanDatesLabel(String start, String due) {
    return 'Started: $start · Due: $due';
  }

  @override
  String loanParticipantsLabel(String borrower, String owner) {
    return 'Borrower: $borrower · Owner: $owner';
  }

  @override
  String get actionAccept => 'Accept';

  @override
  String get actionReject => 'Reject';

  @override
  String get actionMarkReturned => 'Mark returned';

  @override
  String get bookStatsHeader => 'Book statistics';

  @override
  String get totalLabel => 'Total';

  @override
  String get availableLabel => 'Available';

  @override
  String errorLoadingSharedBooks(String error) {
    return 'Error loading shared books: $error';
  }

  @override
  String get successSync => 'Synchronization completed';

  @override
  String get discoverTabTitle => 'Discover';

  @override
  String get discoverTabDesc =>
      'Explore groups you belong to and discover books available to request for loan.';

  @override
  String get noGroupsTitle => 'You don\'t belong to any group yet';

  @override
  String get noGroupsMessage =>
      'Create a group or join with a code to start sharing books and managing loans.';

  @override
  String get actionJoinOrSync => 'Join or sync';

  @override
  String get actionRetry => 'Retry';

  @override
  String get onboardingSlide1Title => 'Your own collection';

  @override
  String get onboardingSlide1Message =>
      'Every book tells a story. Preserve yours, add notes and keep the memory of your readings alive.';

  @override
  String get onboardingSlide2Title => 'Reading Circles';

  @override
  String get onboardingSlide2Message =>
      'Where stories meet. Join communities and discover shared libraries with other readers.';

  @override
  String get onboardingSlide3Title => 'The book\'s journey';

  @override
  String get onboardingSlide3Message =>
      'Track every borrowed copy. Manage returns and share knowledge with confidence.';

  @override
  String get onboardingSlide4Title => 'Cloud Chronicle';

  @override
  String get onboardingSlide4Message =>
      'Your catalog is preserved in Supabase, always available to continue the story from anywhere.';

  @override
  String get actionStartChronicle => 'Start Chronicle';

  @override
  String get actionNextPage => 'Next Page';

  @override
  String get actionSkipPrologue => 'Skip Prologue';

  @override
  String get welcomeToApp => 'Done! Welcome to Book Sharing.';

  @override
  String get stepSkippedHint =>
      'Step skipped. You can configure it later from help.';

  @override
  String get errorSyncingAccount =>
      'We are finishing syncing your account. Try in a few seconds.';

  @override
  String groupAlreadyExists(String name) {
    return 'You already have a group named \"$name\".';
  }

  @override
  String successGroupCreatedWizard(String name) {
    return 'Group \"$name\" created successfully.';
  }

  @override
  String errorCreatingGroupWizard(String error) {
    return 'Couldn\'t create the group: $error';
  }

  @override
  String errorJoiningGroupWizard(String error) {
    return 'Couldn\'t join the group: $error';
  }

  @override
  String get errorLoadingOnboarding =>
      'We couldn\'t load the onboarding state.';

  @override
  String get onboardingWizardTitle => 'Start your story';

  @override
  String get actionSkipIntro => 'Skip Introduction';

  @override
  String get actionSealPact => 'Seal Pact';

  @override
  String get actionContinueWizard => 'Continue';

  @override
  String get actionSkipChapter => 'Skip Chapter';

  @override
  String get wizardStep1Title => 'Chapter 1: The Foundation';

  @override
  String get wizardStep1Subtitle => 'Create a circle to share your volumes.';

  @override
  String get wizardStep1Content =>
      'A group allows you to share books with other members. You can create one now or do it later.';

  @override
  String get syncingAccountTitle => 'Syncing your account...';

  @override
  String get syncingAccountSubtitle =>
      'As soon as we finish you will be able to create groups.';

  @override
  String get groupNameHint => 'E.g. Amateur Reading Club';

  @override
  String get errorGroupNameRequired => 'Enter a name for the group.';

  @override
  String get learnAboutGroupsAction => 'Learn about groups';

  @override
  String get wizardStep2Title => 'Chapter 2: The Alliance';

  @override
  String get wizardStep2Subtitle => 'Join an existing circle via code.';

  @override
  String get wizardStep2Content =>
      'If you have received an invitation, this is the time to answer the call.';

  @override
  String get syncingAccountSubtitleJoin =>
      'We need your active user to validate the code.';

  @override
  String get labelInvitationCode => 'Invitation code';

  @override
  String get invitationCodeHint => 'E.g. 123e4567-e89b-12d3-a456-426614174000';

  @override
  String get errorInvalidCodeWizard =>
      'Enter a valid code or press \"Skip step\".';

  @override
  String get errorCodeTooShort => 'The code is too short.';

  @override
  String get wizardStep3Title => 'Epilogue: Confirmations';

  @override
  String get wizardStep3Subtitle =>
      'Review what is written before closing the book.';

  @override
  String get whatIsGroupTitle => 'What is a group?';

  @override
  String get whatIsGroupContent =>
      'Groups bring together your friends or family to share local libraries. From here you can invite members, manage loans and keep a joint history.';

  @override
  String get whatIsGroupContent2 =>
      'You can create several groups: one for your family, another for your book club, etc. Each group has its own invitations and catalogs.';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusPending => 'Pending';

  @override
  String get almostDoneTitle => 'Almost done!';

  @override
  String get onboardingSummaryMessage =>
      'These are the steps you configured. You can go back if you want to adjust anything before starting.';

  @override
  String get profileConfiguredTitle => 'Profile configured';

  @override
  String userLabel(String name) {
    return 'User: $name';
  }

  @override
  String get firstGroupTitle => 'First group';

  @override
  String get firstGroupSubtitle => 'You created your main community.';

  @override
  String get joinByCodeTitle => 'Join by code';

  @override
  String get joinByCodeSubtitle => 'You joined an existing group.';

  @override
  String get finishOnboardingMessage =>
      'When you press \"Finish\" we will synchronize your information and take you to your library.';

  @override
  String get notificationLoanApproved => 'Loan approved';

  @override
  String get notificationLoanRejected => 'Request rejected';

  @override
  String get notificationLoanCancelled => 'Request cancelled';

  @override
  String get notificationLoanReturned => 'Loan returned';

  @override
  String get notificationLoanExpired => 'Loan expired';

  @override
  String get notificationLoanDueSoon => 'Loan due soon';

  @override
  String get notificationMemberJoined => 'New member joined the group';

  @override
  String get notificationMemberLeft => 'Member left the group';

  @override
  String get notificationGroupUpdated => 'Group updated';

  @override
  String get notificationGroupDeleted => 'Group deleted';

  @override
  String get notificationLoanRequested => 'New loan request';

  @override
  String get actionMarkAsRead => 'Mark as read';

  @override
  String get actionDismiss => 'Dismiss';

  @override
  String get noNotificationsToClear => 'No notifications to clear.';

  @override
  String get errorNoUserToClearNotifications =>
      'Configure an active user before clearing.';

  @override
  String get successNotificationsCleared => 'Notifications cleared.';

  @override
  String errorClearingNotifications(String error) {
    return 'Could not clear notifications: $error';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get actionClearAll => 'Clear All';

  @override
  String get actionClose => 'Close';

  @override
  String get emptyLoansTitle => 'No loan activity';

  @override
  String get emptyLoansMessage =>
      'Your requests and lent books will appear here.';

  @override
  String get emptyLoansAction => 'Register manual loan';

  @override
  String get noNotificationsTitle => 'No notifications';

  @override
  String get noNotificationsMessage =>
      'Here you will see news about your loans and requests.';

  @override
  String get errorLoadingNotifications => 'Could not load';

  @override
  String notificationsTooltip(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $count notifications',
      one: 'You have 1 notification',
      zero: 'Notifications',
    );
    return '$_temp0';
  }

  @override
  String get syncingLabel => 'Syncing...';

  @override
  String get defaultSyncError => 'An error has been encountered.';

  @override
  String get localChangesReadySync => 'Local changes ready to sync.';

  @override
  String get clubDetailProposals => 'Proposals';

  @override
  String get clubDetailMembers => 'Members';

  @override
  String get clubDetailReadingNow => 'READING NOW';

  @override
  String get clubDetailNoActiveBook => 'No active book';

  @override
  String get clubDetailAddBook => 'Add Book';

  @override
  String get clubDetailDiscussion => 'Discussion';

  @override
  String get clubDetailUpdateProgress => 'Update';

  @override
  String get clubDetailNoProposals => 'No active proposals';

  @override
  String get clubDetailProposalUnavailable =>
      'Details not available for this proposed book';

  @override
  String get clubDetailUnknownAuthor => 'Unknown author';

  @override
  String clubDetailSection(Object current, Object total) {
    return 'Section $current/$total';
  }

  @override
  String get clubMembersTitle => 'Club Members';

  @override
  String get clubMembersEmpty => 'No members (this is weird)';

  @override
  String get clubMembersKick => 'Kick';

  @override
  String clubMembersKickConfirmTitle(String username) {
    return 'Kick $username?';
  }

  @override
  String get clubMembersKickConfirmMessage =>
      'This action will remove the user from the club. Are you sure?';

  @override
  String get clubMembersKickSuccess => 'User kicked';

  @override
  String get clubMembersRoleOwner => 'Admin';

  @override
  String get clubMembersRoleMember => 'Mem.';

  @override
  String get clubProposalsTitle => 'Reading Proposals';

  @override
  String get clubProposalsEmpty => 'No active proposals';

  @override
  String get clubProposalsPropose => 'Propose';

  @override
  String get clubProposalsLoginRequired => 'You must login to vote';

  @override
  String clubProposalsChapters(Object count) {
    return '$count ch';
  }

  @override
  String get clubSettingsTitle => 'Club Settings';

  @override
  String get clubSettingsSaved => 'Settings saved';

  @override
  String get clubSettingsName => 'Club Name';

  @override
  String get clubSettingsDescription => 'Description';

  @override
  String get clubSettingsCity => 'Meeting place';

  @override
  String get clubSettingsFrequency => 'Reading frequency';

  @override
  String get clubSettingsCustomFrequency => 'Custom Frequency';

  @override
  String get clubSettingsCustomFrequencyDays =>
      'Days assigned to read each section';

  @override
  String get clubSettingsDeleteButton => 'Delete Club';

  @override
  String get clubSettingsDeleteTitle => 'Delete Club?';

  @override
  String get clubSettingsDeleteMessage =>
      'This action cannot be undone. All club data will be deleted.';

  @override
  String get clubSettingsDeleteSuccess => 'Club deleted';

  @override
  String get clubListCreateGroup => 'Create Group';

  @override
  String get clubListJoinByCode => 'Join by code';

  @override
  String get clubListEmpty => 'You don\'t have any reading clubs yet';

  @override
  String get clubListJoinTitle => 'Join Club';

  @override
  String get clubListJoinIdLabel => 'Club ID';

  @override
  String get clubListJoinIdHint => 'Enter the club UUID code';

  @override
  String get sectionDiscussionLoginRequired => 'You must login to comment';

  @override
  String sectionDiscussionTitle(Object number) {
    return 'Section $number Discussion';
  }

  @override
  String get sectionDiscussionFirstComment => 'Be the first to comment';

  @override
  String get sectionDiscussionHint => 'Write a comment...';

  @override
  String get lockScreenTitle => 'Unlock your library';

  @override
  String get lockScreenSubtitle => 'Enter your key to access';

  @override
  String get lockScreenBiometric => 'Use fingerprint';

  @override
  String get lockScreenThrottled =>
      'The lock is jammed temporarily. Wait a moment.';

  @override
  String get pinSetupNameLabel => 'Name or Alias';

  @override
  String get pinSetupNameHint => 'E.g. The Librarian';

  @override
  String get pinSetupPinLabel => 'Forge your master key (4 digits)';

  @override
  String get pinSetupConfirmLabel => 'Confirm the key';

  @override
  String get pinSetupExistingAccount =>
      'Already have an account? Recover it here';

  @override
  String get loginTitle => 'Login with existing user';

  @override
  String get loginUsernameLabel => 'Username';

  @override
  String get loginUsernameHint => 'E.g. reader_anna';

  @override
  String get loginSubmit => 'Login';

  @override
  String get loginBack => 'Back';

  @override
  String get addBookToClubTitle => 'Add Book';

  @override
  String get addBookToClubSelectBook => 'Select a book';

  @override
  String get addBookToClubInvalidChapters => 'Enter a valid number of chapters';

  @override
  String get addBookToClubAdded => 'Book added to the club';

  @override
  String get addBookToClubSearchHint => 'Search book (Local or Google Books)';

  @override
  String get addBookToClubNoResults => 'No books found';

  @override
  String get addBookToClubLocalSection => 'In your library';

  @override
  String get addBookToClubGoogleSection => 'On Google Books';

  @override
  String get addBookToClubChaptersLabel => 'Number of Chapters';

  @override
  String get addBookToClubSectionMode => 'Sections Mode';

  @override
  String get addBookToClubStartDate => 'Start Date';

  @override
  String get addBookToClubSelectDate => 'Select';

  @override
  String get createClubTitle => 'Create Reading Club';

  @override
  String get createClubSuccess => 'Club created successfully';

  @override
  String get createClubNameLabel => 'Club Name';

  @override
  String get createClubDescriptionLabel => 'Description';

  @override
  String get createClubCityLabel => 'City';

  @override
  String get createClubFrequencyLabel => 'Reading Frequency';

  @override
  String get createClubCustomFrequency => 'Custom Frequency';

  @override
  String get createClubCustomDays => 'Days assigned to read each section';

  @override
  String get proposeBookTitle => 'Propose Book';

  @override
  String get proposeBookSuccess => 'Book proposed successfully';

  @override
  String get proposeBookSelectBook => 'Select a book';

  @override
  String get proposeBookSearchHint => 'Search book (Local or Google Books)';

  @override
  String get proposeBookNoResults => 'No books found';

  @override
  String get proposeBookLocalSection => 'In your library';

  @override
  String get proposeBookGoogleSection => 'On Google Books';

  @override
  String get proposeBookChaptersLabel => 'Number of Chapters';

  @override
  String get updateProgressTitle => 'Update Progress';

  @override
  String get updateProgressSectionLabel => 'Which section are you on?';

  @override
  String get updateProgressStatusLabel => 'Reading status';

  @override
  String get bookFormGenres => 'Genres';

  @override
  String get bookFormAddGenre => 'Add genre';

  @override
  String get bookFormTitle => 'Title';

  @override
  String get bookFormAuthor => 'Author';

  @override
  String get bookFormIsbn => 'ISBN';

  @override
  String get bookFormIsbnOptional => 'ISBN (optional)';

  @override
  String get bookFormAuthorOptional => 'Author (optional)';

  @override
  String get bookFormBarcode => 'Barcode';

  @override
  String get bookFormScanBarcode => 'Scan code';

  @override
  String get bookFormPages => 'Pages';

  @override
  String get bookFormPageHint => 'E.g. 350';

  @override
  String get bookFormYear => 'Publication year';

  @override
  String get bookFormYearHint => 'E.g. 2020';

  @override
  String get bookFormNotes => 'Notes';

  @override
  String get bookFormShareBook => 'Share book';

  @override
  String get bookFormAvailable => 'Available';

  @override
  String get bookFormPrivate => 'Private';

  @override
  String get bookFormLoaned => 'Loaned';

  @override
  String get bookFormClearForm => 'Clear form';

  @override
  String get bookFormStatus => 'Book status';

  @override
  String get bookFormReadingStatus => 'Reading status';

  @override
  String get bookFormDuplicateTitle => 'Duplicate book';

  @override
  String get bookFormUnderstood => 'Understood';

  @override
  String get bookFormDeleteTitle => 'Delete book';

  @override
  String bookFormDeleteMessage(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get bookFormSelectGenresTitle => 'Select genres';

  @override
  String get bookFormSearchGenre => 'Search genre...';

  @override
  String get bookFormNoActiveUser =>
      'You need an active user to share your books.';

  @override
  String get bookDetails => 'Book Details';

  @override
  String get bookDetailsSynopsis => 'Synopsis';

  @override
  String get bookDetailsWhoRead => 'Who has read it?';

  @override
  String get bookDetailsOpine => 'Review';

  @override
  String get bookDetailsNoOpinions => 'No reviews yet';

  @override
  String get bookDetailsSeeAllOpinions => 'See all reviews';

  @override
  String get bookDetailsStarted => 'Started';

  @override
  String get bookDetailsFinished => 'Finished';

  @override
  String get bookDetailsDuration => 'Duration';

  @override
  String get bookDetailsPagesRead => 'Pages read';

  @override
  String get bookDetailsAvgRhythm => 'Avg rhythm';

  @override
  String get bookDetailsDigital => 'Digital';

  @override
  String get bookDetailsPhysical => 'Physical';

  @override
  String get timelineTitle => 'Reading timeline';

  @override
  String get timelineUpdateProgress => 'Update progress';

  @override
  String get timelineEmpty => 'You haven\'t logged any progress yet';

  @override
  String get timelineAddFirst => 'Add your first reading milestone';

  @override
  String get timelineDeleteTitle => 'Delete event';

  @override
  String get timelineDeleteMessage =>
      'Are you sure you want to delete this timeline event?';

  @override
  String get timelineEntryEdit => 'Edit';

  @override
  String get timelineEntryDelete => 'Delete';

  @override
  String get loanNoActiveLoans =>
      'No tienes préstamos pendientes o en curso en este momento.';

  @override
  String loanLenderName(String name) {
    return 'Prestamista: $name';
  }

  @override
  String loanBorrowerName(String name) {
    return 'Solicitante: $name';
  }

  @override
  String loanStatusLabel(String status) {
    return 'Estado: $status';
  }

  @override
  String loanRequestedDate(String date) {
    return 'Solicitado: $date';
  }

  @override
  String loanDueDateValue(String date) {
    return 'Vence: $date';
  }

  @override
  String get loanNavigationDetail => 'Navegación a detalle de préstamo';

  @override
  String get loanMarkReturned => 'Marcar devuelto';

  @override
  String get loanMarkReturnedSuccess => 'Préstamo marcado como devuelto';

  @override
  String get loanReturn => 'Devolución';

  @override
  String get loanReturnDoubleConfirm =>
      'Cuando se complete la devolución, ambos debéis confirmarlo.';

  @override
  String get loanConfirmReturn => 'Confirmar devolución';

  @override
  String loanWaitingFor(String name) {
    return 'Esperando a $name';
  }

  @override
  String loanAlreadyConfirmed(String date) {
    return 'Ya has confirmado la devolución el $date.';
  }

  @override
  String get loanForceFinish => 'Forzar finalización';

  @override
  String get loanSendReminder => 'Enviar recordatorio';

  @override
  String loanOtherConfirmed(String name) {
    return '¡$name confirmó!';
  }

  @override
  String get loanFinishConfirmation =>
      'Confirma que has recibido/entregado el libro para finalizar.';

  @override
  String get loanConfirmAndFinish => 'Confirmar y finalizar';

  @override
  String get loanManualLabel => '(Préstamo manual)';

  @override
  String loanInfoReceived(String owner, String dueDate) {
    return 'Recibido de: $owner\nVence: $dueDate';
  }

  @override
  String loanInfoSent(String borrower, String owner, String dueDate) {
    return 'Prestado a: $borrower\nPrestado de: $owner\nVence: $dueDate';
  }

  @override
  String get you => 'Tú';

  @override
  String get borrower => 'Prestatario';

  @override
  String get user => 'Usuario';

  @override
  String get someone => 'Alguien';

  @override
  String get owner => 'Propietario';

  @override
  String get unknownBook => 'Libro desconocido';

  @override
  String get statsActivitySummary => 'Resumen de Actividad';

  @override
  String get statsRealized => 'Realizados';

  @override
  String get statsAccepted => 'Aceptados';

  @override
  String statsErrorLoadingWithDetail(String error) {
    return 'Error loading statistics: $error';
  }

  @override
  String get stats30Days => '30 d';

  @override
  String get statsTotalYear => 'Total año';

  @override
  String get wishlistTitle => 'Lista de Deseos';

  @override
  String get wishlistEmpty => 'Tu lista de deseos está vacía.';

  @override
  String get wishlistEmptySub => 'Añade libros que quieras leer o comprar.';

  @override
  String get wishlistAddToLibrary => 'Añadir a mi biblioteca';

  @override
  String get wishlistRemove => 'Eliminar deseo';

  @override
  String get wishlistNew => 'Nuevo deseo';

  @override
  String get wishlistDeleteConfirm => '¿Eliminar deseo?';

  @override
  String wishlistDeleteMessage(String title) {
    return '\"$title\" se borrará de tu lista.';
  }

  @override
  String get wishlistAlreadyHave => '¿Ya lo tienes?';

  @override
  String wishlistMoveToLibraryConfirm(String title) {
    return '¿Seguro que quieres pasar \"$title\" a tu biblioteca personal? Se quitará de tu lista de deseos.';
  }

  @override
  String get notYet => 'Aún no';

  @override
  String get yesItsMine => '¡Sí, ya es mío!';

  @override
  String get wishlistDefaultDescription => 'Añadido desde mi lista de deseos';

  @override
  String wishlistAddedToLibrary(String title) {
    return '\"$title\" añadido a tu biblioteca personal.';
  }

  @override
  String wishlistErrorMoving(String error) {
    return 'Error al mover a la biblioteca: $error';
  }

  @override
  String bookFoundTitle(String title) {
    return '📚 Encontrado: $title';
  }

  @override
  String get bookNotFoundInfo => 'No se encontró información para este código.';

  @override
  String searchError(String error) {
    return 'Error al buscar: $error';
  }

  @override
  String get wishlistNewTitle => 'Nuevo Deseo';

  @override
  String get bookAuthorOptional => 'Autor (opcional)';

  @override
  String get isbnOptional => 'ISBN (opcional)';

  @override
  String get wishlistNotesHint => 'Notas / Por qué lo quieres';

  @override
  String get wishlistAddAction => 'Añadir a deseos';

  @override
  String get zenModeNormal => 'Modo Normal';

  @override
  String get zenModeNocturnal => 'Modo Lectura Nocturna';

  @override
  String get remaining => 'restante';

  @override
  String get endSessionAction => 'TERMINAR SESIÓN';

  @override
  String get sessionCompleted => 'Sesión completada';

  @override
  String sessionDurationSummary(String minutes, String title) {
    return '$minutes minutos dedicados a \"$title\"';
  }

  @override
  String get sessionLastPagePrompt => '¿En qué página te has quedado?';

  @override
  String get sessionLastPageHint => 'Ej: 145';

  @override
  String get sessionNotesPrompt => '¿Algo que quieras recordar?';

  @override
  String get sessionNotesHint =>
      'Ej: \"El capítulo con Maga me hizo llorar. Increíble.\"';

  @override
  String get sessionMarkFinished => 'Marcar libro como terminado';

  @override
  String get sessionSaveOnly => 'SOLO GUARDAR';

  @override
  String get sessionSaveAndView => 'GUARDAR Y VER LIBRO';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get timeLabel => 'Tiempo';

  @override
  String get pagesLabel => 'Páginas';

  @override
  String get pagesPerDayLabel => 'Págs/día';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get finishedLabel => 'Terminados';

  @override
  String get rhythmJourneyTitle => 'Tu viaje lector';

  @override
  String get rhythmEmptyState => 'El silencio antes de la historia...';

  @override
  String get securityResetConfirmTitle => '¿Eliminar PIN y salir de la cuenta?';

  @override
  String get securityResetConfirmMessage =>
      'Se eliminarán TODOS los datos locales (libros, grupos, préstamos) y tendrás que iniciar sesión o configurar un nuevo usuario.';

  @override
  String get securityResetConfirmTip =>
      '💡 Tip: Exporta tu biblioteca antes de continuar. Si tienes backups automáticos, búscalos en Descargas/BookSharing/backups.';

  @override
  String get securityResetAction => 'Eliminar todo';

  @override
  String get securityResetSuccess =>
      'Datos eliminados. Reinicia la app para configurar un nuevo usuario.';

  @override
  String get errorActiveSessionRequired => 'Debes tener una sesión activa.';

  @override
  String errorExportingLoans(String error) {
    return 'Error al exportar préstamos: $error';
  }

  @override
  String get errorLoadingTheme => 'No pudimos cargar la preferencia de tema.';

  @override
  String get googleBooksKeyConfigured =>
      'API key configurada. Puedes buscar libros en Google Books.';

  @override
  String get googleBooksKeyNotConfigured =>
      'Configura una API key para buscar libros en Google Books.';

  @override
  String get configApiKey => 'Configurar API key';

  @override
  String get googleBooksKeyHelpTitle => '¿Cómo obtener una API key?';

  @override
  String get googleBooksKeyHelpSteps =>
      '1. Ve a Google Cloud Console\\n2. Crea un nuevo proyecto o selecciona uno existente\\n3. Habilita la \"Books API\"\\n4. Crea credenciales tipo \"API key\"\\n5. Copia la clave y pégala aquí';

  @override
  String get googleBooksKeyDialogTitle => 'Configurar API key de Google Books';

  @override
  String get googleBooksKeyDialogDesc =>
      'Introduce tu API key de Google Books para poder buscar libros.';

  @override
  String get googleBooksKeyHint => 'Pega tu API key aquí';

  @override
  String get googleBooksKeyValidationTip =>
      'Puedes validar la API key antes de guardarla.';

  @override
  String get validateAndSave => 'Validar y guardar';

  @override
  String errorValidatingApiKey(String error) {
    return 'Error al validar API key: $error';
  }

  @override
  String get apiKeySavedSuccess => 'API key guardada correctamente.';

  @override
  String errorSavingApiKey(String error) {
    return 'Error al guardar API key: $error';
  }

  @override
  String get googleBooksKeyDeleteTitle => '¿Eliminar API key de Google Books?';

  @override
  String get googleBooksKeyDeleteDesc =>
      'Se eliminará la API key guardada. La búsqueda de libros en Google Books dejará de funcionar hasta que configures una nueva key.';

  @override
  String get apiKeyDeletedSuccess => 'API key eliminada.';

  @override
  String errorDeletingApiKey(String error) {
    return 'Error al eliminar API key: $error';
  }

  @override
  String get backupPermissionDesc =>
      'Para guardar y restaurar backups en la carpeta de Descargas, necesitamos acceso a todos los archivos.\\n\\nPor favor, concede el permiso en la siguiente pantalla.';

  @override
  String get errorStoragePermissionRequired =>
      'Se requiere permiso de almacenamiento para guardar el backup.';

  @override
  String get autoBackupEnabled => 'Backup automático semanal activado';

  @override
  String get autoBackupDisabled => 'Backup automático desactivado';

  @override
  String errorChangingBackupConfig(String error) {
    return 'Error al cambiar configuración: $error';
  }

  @override
  String get creatingBackup => 'Creando copia de seguridad...';

  @override
  String backupSavedAt(String path) {
    return 'Backup guardado en: $path';
  }

  @override
  String get errorCreatingBackup =>
      'No se pudo crear el backup. Intenta de nuevo.';

  @override
  String errorCreatingBackupDetail(String error) {
    return 'Error al crear backup: $error';
  }

  @override
  String get restoreLatestBackupTitle => '¿Restaurar último backup automático?';

  @override
  String get restoreBackupWarning =>
      'Esta acción reemplazará TODOS tus datos actuales con la copia de seguridad más reciente.';

  @override
  String get searchingBackups => 'Buscando backups...';

  @override
  String get noBackupsFound => 'No se encontraron backups automáticos.';

  @override
  String restoringBackup(String filename) {
    return 'Restaurando $filename...';
  }

  @override
  String get restoreComplete => 'Restauración completada. Reiniciando...';

  @override
  String errorRestoringBackup(String error) {
    return 'Error al restaurar: $error';
  }

  @override
  String get restoreSpecificBackupTitle => '¿Restaurar este backup?';

  @override
  String get restore => 'Restore';

  @override
  String get appRestartNote =>
      'The application will restart automatically after restoration.';

  @override
  String get deleteAction => 'Delete';

  @override
  String get permissionRequired => 'Permission required';

  @override
  String get continueLabel => 'Continue';

  @override
  String get warningLabel => 'Warning';

  @override
  String backupFileLabel(String filename) {
    return 'Archivo: $filename';
  }

  @override
  String errorResettingDatabase(String error) {
    return 'Error al resetear la base de datos: $error';
  }

  @override
  String get deleteCoversTitle => '¿Borrar todas las portadas?';

  @override
  String get deleteCoversDesc =>
      'Se eliminarán todas las imágenes de portada descargadas. Podrás volver a descargarlas manualmente desde la biblioteca.';

  @override
  String coversDeletedCount(String count) {
    return 'Se eliminaron $count portadas.';
  }

  @override
  String errorDeletingCovers(String error) {
    return 'Error al borrar portadas: $error';
  }

  @override
  String get importBooksDialogTitle => 'Importar libros';

  @override
  String get importBooksDialogDesc =>
      'Selecciona un archivo CSV o JSON para importar tus libros.';

  @override
  String get selectFile => 'Seleccionar archivo';

  @override
  String importSuccessCount(String count) {
    return 'Se importaron $count libros correctamente';
  }

  @override
  String importFailureCount(String count) {
    return ' ($count fallidos)';
  }

  @override
  String importMoreErrors(String count) {
    return ' (y $count más...)';
  }

  @override
  String get errorNoBooksImported => 'No se pudo importar ningún libro';

  @override
  String get errorNoActiveUserImport =>
      'No hay usuario activo para importar los libros.';

  @override
  String get errorUnsupportedFileFormat => 'Formato de archivo no soportado';

  @override
  String get releaseNotesTitle => 'New Chapters!';

  @override
  String versionLabel(String version) {
    return 'Versión $version';
  }

  @override
  String get releaseNotesAction => '¡A seguir leyendo!';

  @override
  String get bookshelfSearchTooltip => 'Buscar en mis lecturas';

  @override
  String get bookshelfThemeTooltip => 'Personalizar estantería';

  @override
  String get bookshelfManageTooltip => 'Gestionar títulos';

  @override
  String get bookshelfSearchHint => 'Buscar por título o autor...';

  @override
  String get bookshelfCustomTitle => 'Personalizar Estantería';

  @override
  String get bookshelfTabShelves => 'Baldas';

  @override
  String get bookshelfTabWall => 'Fondo';

  @override
  String get sortRecent => 'Recientes';

  @override
  String get sortAlpha => 'A → Z';

  @override
  String get sortAuthor => 'Autor';

  @override
  String get sortPages => 'Páginas';

  @override
  String get sortRating => 'Valoración';

  @override
  String get shelfThemeClassic => 'Clásica';

  @override
  String get shelfThemeModern => 'Moderna';

  @override
  String get shelfThemeVintage => 'Vintage';

  @override
  String get shelfThemeIndustrial => 'Industrial';

  @override
  String get shelfThemePastel => 'Pastel';

  @override
  String get wallThemePlaster => 'Yeso';

  @override
  String get wallThemeBrick => 'Ladrillo';

  @override
  String get wallThemePaper => 'Papel';

  @override
  String get wallThemeWood => 'Madera';

  @override
  String get wallThemeDark => 'Oscuro';

  @override
  String get statsGeneralTitle => 'Estadísticas generales';

  @override
  String get statsTotalBooks => 'Libros totales';

  @override
  String get statsReadBooks => 'Libros leídos';

  @override
  String get statsAvailable => 'Disponibles';

  @override
  String get statsTotalLoans => 'Préstamos totales';

  @override
  String get statsActiveLoans => 'Préstamos activos';

  @override
  String get statsReturned => 'Devueltos';

  @override
  String get statsExpired => 'Expirados';

  @override
  String get statsViewReadingHistory => 'Ver historial de lecturas';

  @override
  String get statsActiveLoansHeader => 'Préstamos activos';

  @override
  String get statsTopBooksHeader => 'Libros más prestados';

  @override
  String get statsNoTopBooksMessage =>
      'Cuando registres préstamos aparecerán aquí tus libros más populares.';

  @override
  String statsLoanCount(String count) {
    return 'Préstamos registrados: $count';
  }

  @override
  String get statsErrorLoading => 'We couldn\'t load the statistics.';

  @override
  String get statsRecommendationsTitle => 'Recomendaciones para ti';

  @override
  String get statsUnknownAuthor => 'Autor desconocido';

  @override
  String get loanManualTitle => 'Nuevo Préstamo Manual';

  @override
  String get loanReceiveTitle => 'Registrar libro prestado';

  @override
  String get loanReceiveDescription =>
      'Registra un libro que alguien (fuera de la app) te ha prestado.';

  @override
  String get loanWhoLentIt => '¿Quién te lo prestó?';

  @override
  String get loanLenderNameRequired => 'Nombre del propietario *';

  @override
  String get loanLenderNameRequiredError =>
      '¿Quién es el guardián de este libro?';

  @override
  String get lenderLabel => 'Propietario:';

  @override
  String loanErrorRegister(String error) {
    return 'Error al registrar: $error';
  }

  @override
  String get isbnInvalid => 'ISBN no válido';

  @override
  String get bookNotFound => 'No se encontró el libro';

  @override
  String get searchPromptTitleOrIsbn => 'Introduce título o ISBN';

  @override
  String get searchNoResults => 'Sin resultados';

  @override
  String get searchSelectResult => 'Selecciona un resultado';

  @override
  String get unknownAuthor => 'Autor desconocido';

  @override
  String get permissionCameraDenied => 'Permiso de cámara denegado';

  @override
  String get scanBarcode => 'Scan code';

  @override
  String get searching => 'Buscando...';

  @override
  String get searchData => 'Buscar datos';

  @override
  String get bookTitleRequired => 'Título del libro *';

  @override
  String get bookTitleRequiredError => '¿Cómo se llama la historia?';

  @override
  String get loanBookToLend => 'Libro a prestar';

  @override
  String get loanNoAvailableBooks =>
      'No tienes libros disponibles para prestar.';

  @override
  String get loanSelectBook => 'Selecciona un libro';

  @override
  String loanErrorLoadingBooks(String error) {
    return 'Error cargando libros: $error';
  }

  @override
  String get loanBorrowerData => 'Datos del prestatario';

  @override
  String get loanFullName => 'Nombre Completo';

  @override
  String get loanFullNameHint => 'Ej. Juan Pérez';

  @override
  String get loanNameRequired => 'El nombre es requerido';

  @override
  String get loanContactOptional => 'Contacto (Opcional)';

  @override
  String get loanContactHint => 'Teléfono, email o nota';

  @override
  String get loanDueDate => 'Fecha de devolución';

  @override
  String get loanIndefinite => 'Indefinido';

  @override
  String get loanNoDueDate => 'Sin fecha límite';

  @override
  String get loanRegister => 'Registrar Préstamo';

  @override
  String get loanRegisteredSuccess => 'Préstamo registrado';

  @override
  String get borrowerLabel => 'Prestatario:';

  @override
  String get dueLabel => 'Vence:';

  @override
  String get understood => 'Entendido';

  @override
  String get saving => 'Guardando...';

  @override
  String get timelineStart => 'Inicio';

  @override
  String get timelineProgress => 'Progreso';

  @override
  String get timelinePause => 'Pausa';

  @override
  String get timelineResume => 'Reanudación';

  @override
  String get timelineFinish => 'Finalizado';

  @override
  String timelinePage(int number) {
    return 'Página $number';
  }

  @override
  String get addTimelineDate => 'Date';

  @override
  String get addTimelineCurrentPage => 'Current page (optional)';

  @override
  String get addTimelineNote => 'Personal note (optional)';

  @override
  String get addTimelineNoteHint => 'Your impressions, thoughts...';

  @override
  String get addTimelineInvalidPage => 'Please enter a valid page number';

  @override
  String get addTimelineEditTitle => 'Editar progreso';

  @override
  String get addTimelineAddTitle => 'Añadir progreso';

  @override
  String addTimelineToday(String time) {
    return 'Hoy, $time';
  }

  @override
  String addTimelineYesterday(String time) {
    return 'Ayer, $time';
  }

  @override
  String addTimelineTotalPagesHint(int count) {
    return 'De $count páginas';
  }

  @override
  String get addTimelinePageNumberHint => 'Número de página';

  @override
  String get addTimelineUpdateSuccess => 'Progreso actualizado';

  @override
  String get addTimelineAddSuccess => 'Progreso añadido';

  @override
  String reviewDialogTitle(String title) {
    return 'How would you recommend \"$title\"?';
  }

  @override
  String get reviewDialogOptionalComment => 'Write a review (optional)';

  @override
  String get reviewDialogCommentHint =>
      'Share your thoughts about this book...';

  @override
  String get reviewDialogAdded => 'Review added.';

  @override
  String get reviewDialogRecommendTitle => 'Who do you recommend it to?';

  @override
  String get reviewDialogRecommendMessage =>
      'You gave a positive rating. Want to send a message to someone recommending it?';

  @override
  String get reviewDialogNotNow => 'Not now';

  @override
  String get reviewDialogRecommend => 'Recommend';

  @override
  String get reviewDialogWriteTitle => 'Escribe una reseña';

  @override
  String reviewDialogByAuthor(String author) {
    return 'por $author';
  }

  @override
  String get reviewListEdit => 'Edit review';

  @override
  String get readStatusFilterAll => 'All books';

  @override
  String get readStatusFilterRead => 'Read';

  @override
  String get readStatusFilterUnread => 'Unread';

  @override
  String get libraryEmpty => 'Your library is empty';

  @override
  String get libraryEmptyMessage =>
      'Register your first book to organize loans and share readings with your group.';

  @override
  String get libraryRegister => 'Register book';

  @override
  String get searchBarHint => 'Search by title or author...';

  @override
  String get exportCSV => 'Export as CSV';

  @override
  String get exportJSON => 'Export as JSON';

  @override
  String get exportPDF => 'Export as PDF';

  @override
  String get export => 'Exportar';

  @override
  String get exportNoBooks => 'No hay libros para exportar.';

  @override
  String exportError(String error) {
    return 'No se pudo exportar: $error';
  }

  @override
  String get refreshMetadata => 'Refresh metadata';

  @override
  String get refreshMetadataMessage =>
      'Missing covers and data (pages, year, genre) will be searched for your books.';

  @override
  String get refreshMetadataWaitMessage =>
      'Se buscarán portadas y datos faltantes (páginas, año, género) para tus libros. Esto puede tardar varios minutos dependiendo de cuántos libros tengas.';

  @override
  String get refreshOnlyMissing => 'Only missing';

  @override
  String get refreshForceAll => 'Force all';

  @override
  String get refreshingMetadata => 'Actualizando metadatos...';

  @override
  String get refreshMetadataNone =>
      'Todos los libros ya tienen metadatos completos.';

  @override
  String refreshMetadataSuccess(int success, int total) {
    return 'Metadatos actualizados: $success de $total.';
  }

  @override
  String refreshMetadataError(String error) {
    return 'Error al actualizar metadatos: $error';
  }

  @override
  String get coverGallery => 'Gallery';

  @override
  String get coverCamera => 'Camera';

  @override
  String get coverDelete => 'Delete';

  @override
  String get readingStatusTitle => 'Estado de lectura';

  @override
  String readingStatusChanged(String status) {
    return 'Estado cambiado a: $status';
  }

  @override
  String readingStatusError(String error) {
    return 'Error al cambiar estado: $error';
  }

  @override
  String get insightJustStarted => 'Acabas de empezar este libro';

  @override
  String get insightNearlyFinished => 'Estás a punto de terminar este libro';

  @override
  String get insightReflective =>
      'Este libro parece invitar a pausas y reflexión';

  @override
  String get insightDevoured => 'Has devorado este libro con entusiasmo';

  @override
  String get insightFastPace => 'Una lectura vertiginosa, difícil de soltar';

  @override
  String get insightSlowPace =>
      'Estás saboreando este libro con calma, sin prisas';

  @override
  String get insightSteadyPace => 'Llevas un ritmo constante con este libro';

  @override
  String get insightFinishedFast =>
      '¡Lo leíste de un tirón! Otra aventura vivida.';

  @override
  String get insightFinishedNormal =>
      'Un viaje completado. Cada página, un paso más.';

  @override
  String get insightFinishedSlow =>
      'Terminado. Las historias que duran también dejan huella.';

  @override
  String get recommendLevel1 => 'No lo recomendaría';

  @override
  String get recommendLevel2 => 'Está bien, pero no es para mí';

  @override
  String get recommendLevel3 => 'Lo recomiendo a gente como yo';

  @override
  String get recommendLevel4 => 'Todo el mundo debería leerlo';

  @override
  String get recommendLevel5 => 'Lo terminé, pero me costó';

  @override
  String get recommendLevel1Short => 'No recomendado';

  @override
  String get recommendLevel2Short => 'Ni fu ni fa';

  @override
  String get recommendLevel3Short => 'Recomendado';

  @override
  String get recommendLevel4Short => 'Imprescindible';

  @override
  String get recommendLevel5Short => 'Terminado con esfuerzo';

  @override
  String bookDetailsIsbn(String isbn) {
    return 'ISBN: $isbn';
  }

  @override
  String get coverNoCover => 'Sin portada';

  @override
  String get coverSelected => 'Portada seleccionada';

  @override
  String get coverHelp => 'Añade una imagen para identificar mejor tus libros.';

  @override
  String get coverNotAvailable => 'Portadas no disponibles en esta plataforma';

  @override
  String get selectGenresTitle => 'Select genres';

  @override
  String get searchGenreHint => 'Search genre...';

  @override
  String bookSourceFound(String source) {
    return 'Source: $source';
  }

  @override
  String get manualLoanTitle => 'New Manual Loan';

  @override
  String get manualLoanBookSection => 'Book to lend';

  @override
  String get manualLoanNoBooksAvailable =>
      'You don\'t have available books to lend.';

  @override
  String get manualLoanSelectBook => 'Select a book';

  @override
  String get manualLoanBorrowerSection => 'Borrower details';

  @override
  String get manualLoanFullName => 'Full Name';

  @override
  String get manualLoanFullNameHint => 'E.g. John Doe';

  @override
  String get manualLoanContact => 'Contact (Optional)';

  @override
  String get manualLoanContactHint => 'Phone, email or note';

  @override
  String get manualLoanDueDate => 'Due date';

  @override
  String get manualLoanIndefinite => 'Indefinite';

  @override
  String get manualLoanRegistered => 'Loan registered';

  @override
  String get receiveExternalTitle => 'Register borrowed book';

  @override
  String get receiveExternalSubtitle =>
      'Register a book someone (outside the app) lent to you.';

  @override
  String get receiveExternalBookSection => 'Book details';

  @override
  String get receiveExternalTitleLabel => 'Book title *';

  @override
  String get receiveExternalAuthor => 'Author';

  @override
  String get receiveExternalOwnerSection => 'Who lent it to you?';

  @override
  String get receiveExternalOwnerLabel => 'Owner\'s name *';

  @override
  String get receiveExternalContact => 'Contact (Optional)';

  @override
  String get receiveExternalContactHint => 'Phone, email, etc.';

  @override
  String get receiveExternalDueDate => 'Due date';

  @override
  String get receiveExternalIndefinite => 'Indefinite';

  @override
  String get receiveExternalRegister => 'Register loan';

  @override
  String get loanConfirmMarkReturned => 'Mark Returned';

  @override
  String get loanConfirmConfirmReturn => 'Confirm return';

  @override
  String get loanConfirmSendReminder => 'Send reminder';

  @override
  String get loanConfirmForceFinish => 'Force finish';

  @override
  String get loanConfirmFinish => 'Confirm and finish';

  @override
  String get activeLoansEmpty =>
      'You have no pending or active loans at the moment.';

  @override
  String get loanStatsTitle => 'Activity Summary';

  @override
  String get loanStatsMade => 'Made';

  @override
  String get loanStatsRequests => 'Requests';

  @override
  String get loanStatsAccepted => 'Accepted';

  @override
  String get wishlistAddTitle => 'New Wish';

  @override
  String get wishlistTitleLabel => 'Book title';

  @override
  String get wishlistScanBarcode => 'Scan barcode';

  @override
  String get wishlistAuthorOptional => 'Author (optional)';

  @override
  String get wishlistAddButton => 'Add to wishes';

  @override
  String get readingStatsThisWeek => 'This week';

  @override
  String get readingStatsThisMonth => 'This month';

  @override
  String get readingStatsTime => 'Time';

  @override
  String get readingStatsPages => 'Pages';

  @override
  String get readingStatsFinished => 'Finished';

  @override
  String get readingRhythmEmpty => 'The silence before the story...';

  @override
  String get importBooksTitle => 'Import books';

  @override
  String get importBooksMessage =>
      'Select a CSV or JSON file to import your books.';

  @override
  String get importSelectFile => 'Select file';

  @override
  String get releaseNotesClose => 'Keep reading!';

  @override
  String get reviewWidgetActiveUser => 'You need an active user';

  @override
  String reviewDialogListTitle(String title) {
    return 'Opiniones de \"$title\"';
  }

  @override
  String reviewWidgetError(String error) {
    return 'Error al guardar reseña: $error';
  }

  @override
  String reviewWidgetErrorLoad(String error) {
    return 'Error al cargar opiniones: $error';
  }

  @override
  String get reviewWidgetRating => 'Rating';

  @override
  String get reviewWidgetComment => 'Comment (optional)';

  @override
  String get reviewWidgetCommentHint =>
      'Share your thoughts about this book...';

  @override
  String get actionSeeAll => 'See all';

  @override
  String get actionManage => 'Manage';

  @override
  String get clubRoleOwner => 'Owner';

  @override
  String get clubRoleAdmin => 'Admin';

  @override
  String get clubStatusActive => 'Active';

  @override
  String get clubStatusInactive => 'Inactive';
}
