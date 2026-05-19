/// All user-facing strings centralised here.
/// No widget may contain a hardcoded string literal.
abstract class S {
  // ── App ───────────────────────────────────────────────────────────────────
  static const appName = 'PAEGo';
  static const appTagline = 'School Feeding Programme';

  // ── Splash ────────────────────────────────────────────────────────────────
  static const splashLoading = 'Loading…';

  // ── Login ─────────────────────────────────────────────────────────────────
  static const loginTitle = 'Welcome back';
  static const loginSubtitle = 'Sign in to continue';
  static const loginEmail = 'Username or email';
  static const loginPassword = 'Password';
  static const loginButton = 'Sign in';
  static const loginNoAccount = 'Need access?';
  static const loginRegister = 'Contact admin';
  static const loginForgot = 'Forgot password?';
  static const loginRequired = 'This field is required';
  static const loginInvalidEmail = 'Enter a valid email';
  static const loginInvalidCredentials = 'Invalid email or password';
  static const loginRegistrationDisabled =
      'User registration is handled only by an administrator.';

  // ── Register ──────────────────────────────────────────────────────────────
  static const registerTitle = 'Create account';
  static const registerSubtitle = 'Join the PAEGo network';
  static const registerFullName = 'Full name';
  static const registerEmail = 'Email';
  static const registerPhone = 'Phone number';
  static const registerPassword = 'Password';
  static const registerConfirmPassword = 'Confirm password';
  static const registerRole = 'Role';
  static const registerIdNumber = 'ID number';
  static const registerInstitution = 'Institution (optional)';
  static const registerButton = 'Create account';
  static const registerHaveAccount = 'Already have an account?';
  static const registerSignIn = 'Sign in';
  static const registerPasswordMismatch = 'Passwords do not match';
  static const registerSuccess = 'Account created successfully';
  static const registerPhotoUpload = 'Upload photo';
  static const registerDisabledTitle = 'Registration disabled';
  static const registerDisabledMessage =
      'Only an administrator can create user accounts.';
  static const registerBackToLogin = 'Back to sign in';

  // ── Roles ─────────────────────────────────────────────────────────────────
  static const roleSuperAdmin = 'Super Admin';
  static const roleAdmin = 'Admin';
  static const roleRector = 'Rector';
  static const roleDriver = 'Driver';

  static const roleDescSuperAdmin = 'Full system access — view and manage everything.';
  static const roleDescAdmin = 'Manage deliveries and drivers in your municipality.';
  static const roleDescRector = 'Track deliveries to your school and submit reports.';
  static const roleDescDriver = 'Accept orders and navigate delivery routes.';

  // ── Home / Dashboard ──────────────────────────────────────────────────────
  static const dashboardWelcome = 'Good morning';
  static const dashboardActiveDeliveries = 'Active deliveries';
  static const dashboardPendingOrders = 'Pending orders';
  static const dashboardDriversOnline = 'Drivers online';
  static const dashboardReportsToday = 'Reports today';
  static const dashboardQuickActions = 'Quick actions';
  static const dashboardRecentActivity = 'Recent activity';

  // ── Navigation ────────────────────────────────────────────────────────────
  static const navHome = 'Home';
  static const navMap = 'Map';
  static const navMessages = 'Messages';
  static const navReports = 'Reports';
  static const navProfile = 'Profile';

  // ── Map ───────────────────────────────────────────────────────────────────
  static const mapTitle = 'Live Map';
  static const mapSubtitle = 'Real-time tracking';
  static const mapMyLocation = 'My current location';
  static const mapAddSchool = 'Add school location';
  static const mapSchoolName = 'School name';
  static const mapSchoolAddress = 'Address';
  static const mapSaveLocation = 'Save location';
  static const mapSelectOnMap = 'Tap on the map to place pin';
  static const mapNoVehicles = 'No vehicles currently tracked';
  static const mapStartRoute = 'Start route';
  static const mapStopRoute = 'Stop route';
  static const mapSendLocation = 'Sending location…';
  static const mapVehiclesActive = 'vehicles active';

  // ── Deliveries / Orders ───────────────────────────────────────────────────
  static const orderTitle = 'Orders';
  static const orderAvailable = 'Available orders';
  static const orderMyActive = 'My active order';
  static const orderStatusPending = 'Pending';
  static const orderStatusAssigned = 'Assigned';
  static const orderStatusEnRoute = 'En route';
  static const orderStatusDelivered = 'Delivered';
  static const orderClaimButton = 'Accept order';
  static const orderStartButton = 'Start delivery';
  static const orderCompleteButton = 'Mark delivered';
  static const orderNoOrders = 'No orders available';
  static const orderSchool = 'School';
  static const orderPickup = 'Pickup point';
  static const orderDistance = 'Distance';

  // ── Reports ───────────────────────────────────────────────────────────────
  static const reportTitle = 'Delivery Reports';
  static const reportNew = 'New report';
  static const reportCondition = 'Food condition';
  static const reportConditionGood = 'Good';
  static const reportConditionFair = 'Fair';
  static const reportConditionPoor = 'Poor';
  static const reportNotes = 'Notes';
  static const reportPhotos = 'Photos';
  static const reportAddPhoto = 'Add photo';
  static const reportSubmit = 'Submit report';
  static const reportSubmitted = 'Report submitted';
  static const reportPendingSync = 'Pending sync';
  static const reportSynced = 'Synced';
  static const reportNoReports = 'No reports yet';
  static const reportSchool = 'School';
  static const reportDate = 'Date';
  static const reportBy = 'Submitted by';
  static const reportViewPhotos = 'View photos';

  // ── Personnel ─────────────────────────────────────────────────────────────
  static const personnelTitle = 'Personnel';
  static const personnelAdd = 'Add personnel';
  static const personnelEmpty = 'No personnel registered yet';
  static const personnelDelete = 'Remove personnel';
  static const personnelDeleteConfirm = 'Remove this person from the system?';
  static const personnelEdit = 'Edit';
  static const personnelAdminOnly =
      'Only administrators can create or remove users.';
  static const personnelCreated = 'User created successfully';
  static const personnelCannotDeleteSelf =
      'You cannot remove your own account';

  // ── Messages ──────────────────────────────────────────────────────────────
  static const messagesTitle = 'Messages';
  static const messagesTypeHere = 'Type a message…';
  static const messagesSend = 'Send';
  static const messagesEmpty = 'No messages yet';

  // ── Settings / Profile ────────────────────────────────────────────────────
  static const settingsTitle = 'Settings';
  static const profileTitle = 'My Profile';
  static const profileEditPhoto = 'Change photo';
  static const profileLogout = 'Log out';
  static const profileLogoutConfirm = 'Are you sure you want to log out?';
  static const profilePrivacy = 'Privacy';
  static const profileNotifications = 'Notifications';
  static const settingsTheme = 'Dark mode';
  static const settingsLanguage = 'Language';
  static const settingsSync = 'Sync data now';
  static const settingsSyncing = 'Syncing…';
  static const settingsSyncDone = 'All data synced';

  // ── Connectivity ──────────────────────────────────────────────────────────
  static const syncOffline = 'Offline — changes saved locally';
  static const syncOnline = 'Back online — syncing data';

  // ── Common ────────────────────────────────────────────────────────────────
  static const cancel = 'Cancel';
  static const confirm = 'Confirm';
  static const save = 'Save';
  static const update = 'Update';
  static const delete = 'Delete';
  static const edit = 'Edit';
  static const close = 'Close';
  static const retry = 'Retry';
  static const loading = 'Loading…';
  static const error = 'Something went wrong';
  static const required = 'Required field';
  static const comingSoon = ' – coming soon';
  static const pageNotFound = 'Page not found';
  static const routeNotFound = 'This route does not exist.';
  static const yes = 'Yes';
  static const no = 'No';
  static const search = 'Search';
  static const noResults = 'No results found';
  static const viewAll = 'View all';
  static const unknown = 'Unknown';
}
