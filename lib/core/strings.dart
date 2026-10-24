// lib/core/strings.dart
// All user-facing strings centralized for easy localization.

class AppStrings {
  AppStrings._();

  // App
  static const appName = 'CricTrack';
  static const tagline = 'Ball tracking from just your phone.';
  static const version = 'Version 1.0.0 (Preview)';

  // Auth
  static const login = 'Login';
  static const phoneNumber = 'Phone Number';
  static const enterPhone = 'Enter your phone number';
  static const sendOtp = 'Send OTP';
  static const verifyOtp = 'Verify OTP';
  static const otpSent = 'OTP sent to';
  static const enterOtp = 'Enter 6-digit OTP';
  static const resendOtp = 'Resend OTP';
  static const selectRole = 'Select your role';
  static const rolePlayer = 'Player';
  static const roleCoach = 'Coach';
  static const roleAnalyst = 'Analyst';
  static const continueBtn = 'Continue';
  static const logout = 'Logout';

  // Navigation
  static const navHome = 'Home';
  static const navSessions = 'Sessions';
  static const navRecord = 'Record';
  static const navProfile = 'Profile';

  // Home
  static const greeting = 'Good';
  static const morning = 'Morning';
  static const afternoon = 'Afternoon';
  static const evening = 'Evening';
  static const startNewSession = 'Start New Session';
  static const startNewSessionSubtitle = 'Record and analyze a new delivery session';
  static const quickStats = 'Quick Stats';
  static const sessionsThisWeek = 'Sessions\nThis Week';
  static const ballsBowled = 'Balls\nBowled';
  static const topSpeed = 'Top Speed\n(km/h)';
  static const avgSpin = 'Avg Spin\n(rpm)';
  static const lastSession = 'Last Session';
  static const highlights = 'Highlights';
  static const viewAll = 'View All';
  static const noSessions = 'No sessions yet';
  static const noSessionsSubtitle = 'Tap the Record button to start your first session.';

  // Setup Guide
  static const setupGuide = 'Setup Guide';
  static const setupTitle = 'Camera Setup Checklist';
  static const setupSubtitle = 'Complete all steps before recording';
  static const startRecording = 'Start Recording';
  static const step1 = '3 stumps at the bowler\'s end (with bails)';
  static const step2 = '3 stumps at the batter\'s end (with bails)';
  static const step3 = 'Tripod placed at ~1.3 m height behind stumps';
  static const step4 = 'Camera positioned ~4 m behind non-striker stumps';
  static const step5 = 'Phone locked in portrait or landscape orientation';
  static const step6 = 'Lighting is adequate (no harsh shadows on pitch)';

  // Recording
  static const recording = 'Recording';
  static const rec = 'REC';
  static const ballsDetected = 'Balls detected';
  static const markBowler = 'Mark Bowler';
  static const stopRecording = 'Stop Recording';
  static const confirmStop = 'Stop Recording?';
  static const confirmStopMsg =
      'The session will be saved and processed. You can review deliveries once processing is complete.';
  static const yes = 'Yes, Stop';
  static const cancel = 'Cancel';
  static const cameraPermissionDenied = 'Camera Permission Denied';
  static const cameraPermissionMsg =
      'CricTrack needs camera access to record delivery sessions.';
  static const openSettings = 'Open Settings';

  // Sessions
  static const sessions = 'My Sessions';
  static const all = 'All';
  static const practice = 'Practice';
  static const match = 'Match';
  static const noSessionsFound = 'No sessions found';
  static const balls = 'balls';
  static const avgSpeed = 'Avg Speed';
  static const share = 'Share';

  // Session Detail
  static const deliveries = 'Deliveries';
  static const pitchMap = 'Pitch Map';
  static const trajectory3D = '3D Trajectory';
  static const stats = 'Stats';
  static const outputs = 'Outputs';
  static const maxSpeed = 'Max Speed';
  static const dotBall = 'Dot %';
  static const accepted = 'Accepted';
  static const uncertain = 'Uncertain';
  static const rejected = 'Rejected';

  // Delivery
  static const speed = 'Speed';
  static const spin = 'Spin';
  static const swing = 'Swing';
  static const line = 'Line';
  static const length = 'Length';
  static const off = 'Off';
  static const middle = 'Middle';
  static const leg = 'Leg';
  static const yorker = 'Yorker';
  static const full = 'Full';
  static const good = 'Good';
  static const short = 'Short';
  static const lbwReview = 'LBW Review';
  static const review = 'Review';
  static const playClip = 'Play Clip';

  // 3D Viewer
  static const showLandingPoint = 'Landing';
  static const showStumps = 'Stumps';
  static const showUncertainty = 'Uncertainty';
  static const rotate = 'Drag to rotate';
  static const pinchZoom = 'Pinch to zoom';
  static const playback = 'Playback';

  // LBW / DRS
  static const lbwAnalysis = 'LBW Analysis';
  static const drsReview = 'DRS Review';
  static const verdict = 'Verdict';
  static const out = 'OUT';
  static const notOut = 'NOT OUT';
  static const umpiresCall = 'UMPIRE\'S CALL';
  static const confidence = 'Confidence';
  static const impactPoint = 'Impact Point';
  static const stumpHittingZone = 'Stump-Hitting Zone';
  static const accept = 'Accept Decision';
  static const requestReview = 'Request Review';
  static const whyUncertain = 'Why uncertain?';

  // Profile
  static const profile = 'Profile';
  static const subscription = 'Subscription';
  static const freePlan = 'Free Plan';
  static const upgradePro = 'Upgrade to Pro';
  static const cloudStorage = 'Cloud Storage';
  static const privacy = 'Privacy Policy';
  static const terms = 'Terms of Service';
  static const developerOptions = 'Developer Options';
  static const showTrajectoryJson = 'Show Trajectory JSON';

  // Share
  static const shareSession = 'Share Session';
  static const shareWith = 'Share with Teammates';
  static const copyLink = 'Copy Link';
  static const linkCopied = 'Link copied to clipboard!';

  // Processing stages
  static const stage1 = 'Ingest & Delivery Discovery';
  static const stage2 = 'Ball Proposal & Center Refinement';
  static const stage3 = 'Single-Ball Tracking & Temporal Identity';
  static const stage4 = 'Global Whole-Delivery Optimization';
  static const stage5 = '2D Smoothing & Calibrated 3D Trajectory';
  static const stage6 = 'Final Acceptance & Product Output';

  // Errors / Misc
  static const error = 'Error';
  static const retry = 'Retry';
  static const loading = 'Loading...';
  static const processing = 'Processing...';
  static const done = 'Done';
  static const failed = 'Failed';
  static const pending = 'Pending';
  static const running = 'Running';

  // Misc
  static const deliveryLabel = 'Delivery';
  static const kmh = 'km/h';
  static const rpm = 'rpm';
  static const deg = '°';
  static const meters = 'm';
}
