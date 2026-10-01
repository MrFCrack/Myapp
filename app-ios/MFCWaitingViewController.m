//
//  MFCWaitingViewController.m
//  Mr-FCrack
//

#import "MFCWaitingViewController.h"
#import <sys/sysctl.h>
#import <sys/types.h>

// Bundle ID de Free Fire MAX
static NSString *const kFFMaxBundleID = @"com.dts.freefiremax";
static NSString *const kFFMaxProcessName = @"FreeFireMAX";

// Intervalo de reintento (segundos)
static const NSTimeInterval kRetryInterval = 2.0;

@interface MFCWaitingViewController ()

@property (nonatomic, strong) UIView *logoCircle;
@property (nonatomic, strong) UILabel *logoLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) NSTimer *retryTimer;
@property (nonatomic, assign) NSInteger attemptCount;

@end

@implementation MFCWaitingViewController

#pragma mark - Ciclo de vida

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startWaiting];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopWaiting];
}

#pragma mark - UI

- (void)setupUI {
    // Logo
    self.logoCircle = [[UIView alloc] init];
    self.logoCircle.backgroundColor = [UIColor colorWithRed:0.5 green:0.2 blue:0.8 alpha:1.0];
    self.logoCircle.layer.cornerRadius = 50;
    self.logoCircle.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.logoCircle];

    self.logoLabel = [[UILabel alloc] init];
    self.logoLabel.text = @"MFC";
    self.logoLabel.textColor = [UIColor whiteColor];
    self.logoLabel.font = [UIFont systemFontOfSize:36 weight:UIFontWeightBold];
    self.logoLabel.textAlignment = NSTextAlignmentCenter;
    self.logoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.logoCircle addSubview:self.logoLabel];

    // Título
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"Mr-FCrack Script";
    self.titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    self.titleLabel.textColor = [UIColor labelColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.titleLabel];

    // Spinner
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.spinner.color = [UIColor colorWithRed:0.5 green:0.2 blue:0.8 alpha:1.0];
    self.spinner.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.spinner];

    // Status
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = @"Esperando Free Fire MAX...";
    self.statusLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    self.statusLabel.textColor = [UIColor labelColor];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.statusLabel];

    // Hint (texto de ayuda)
    self.hintLabel = [[UILabel alloc] init];
    self.hintLabel.text = @"Abre Free Fire MAX para continuar";
    self.hintLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    self.hintLabel.textColor = [UIColor secondaryLabelColor];
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    self.hintLabel.numberOfLines = 0;
    self.hintLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.hintLabel];

    // Layout
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        // Logo
        [self.logoCircle.topAnchor constraintEqualToAnchor:safe.topAnchor constant:80],
        [self.logoCircle.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor],
        [self.logoCircle.widthAnchor constraintEqualToConstant:100],
        [self.logoCircle.heightAnchor constraintEqualToConstant:100],
        [self.logoLabel.centerXAnchor constraintEqualToAnchor:self.logoCircle.centerXAnchor],
        [self.logoLabel.centerYAnchor constraintEqualToAnchor:self.logoCircle.centerYAnchor],

        // Título
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.logoCircle.bottomAnchor constant:24],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:24],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-24],

        // Spinner
        [self.spinner.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:60],
        [self.spinner.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor],

        // Status
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.spinner.bottomAnchor constant:24],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:24],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-24],

        // Hint
        [self.hintLabel.topAnchor constraintEqualToAnchor:self.statusLabel.bottomAnchor constant:16],
        [self.hintLabel.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:24],
        [self.hintLabel.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-24],
    ]];
}

#pragma mark - Espera

- (void)startWaiting {
    [self.spinner startAnimating];
    self.attemptCount = 0;

    // Primer intento inmediato
    [self tryFindGame];

    // Timer de reintento
    self.retryTimer = [NSTimer scheduledTimerWithTimeInterval:kRetryInterval
                                                       target:self
                                                     selector:@selector(tryFindGame)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)stopWaiting {
    [self.spinner stopAnimating];
    if (self.retryTimer) {
        [self.retryTimer invalidate];
        self.retryTimer = nil;
    }
}

- (void)tryFindGame {
    self.attemptCount++;

    NSLog(@"[Waiting] intento #%ld buscando Free Fire MAX...", (long)self.attemptCount);

    // Buscar el proceso de Free Fire MAX
    pid_t pid = [self findProcessPID:kFFMaxProcessName];

    if (pid > 0) {
        NSLog(@"[Waiting] ✅ Free Fire MAX encontrado (pid: %d)", pid);

        // Actualizar UI
        self.statusLabel.text = @"¡Free Fire MAX encontrado!";
        self.statusLabel.textColor = [UIColor systemGreenColor];
        self.hintLabel.text = @"Conectando...";

        [self stopWaiting];

        // Avanzar después de un pequeño delay (para que se vea el mensaje)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            if (self.onGameFound) {
                self.onGameFound();
            }
        });
    } else {
        // Aún no encontrado
        self.statusLabel.text = @"Esperando Free Fire MAX...";
        self.hintLabel.text = @"Abre Free Fire MAX para continuar";
    }
}

#pragma mark - Búsqueda de proceso

- (pid_t)findProcessPID:(NSString *)processName {
    // Usar sysctl para listar procesos
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t size = 0;

    if (sysctl(mib, 4, NULL, &size, NULL, 0) == -1) {
        return 0;
    }

    struct kinfo_proc *procs = malloc(size);
    if (!procs) return 0;

    if (sysctl(mib, 4, procs, &size, NULL, 0) == -1) {
        free(procs);
        return 0;
    }

    int count = (int)(size / sizeof(struct kinfo_proc));
    pid_t foundPID = 0;

    for (int i = 0; i < count; i++) {
        pid_t pid = procs[i].kp_proc.p_pid;
        if (pid <= 0) continue;

        NSString *name = [NSString stringWithUTF8String:procs[i].kp_proc.p_comm];
        if (name && [name isEqualToString:processName]) {
            foundPID = pid;
            break;
        }
    }

    free(procs);
    return foundPID;
}

#pragma mark - Cleanup

- (void)dealloc {
    [self stopWaiting];
}

@end
