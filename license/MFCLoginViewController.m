//
//  MFCLoginViewController.m
//  Mr-FCrack
//

#import "MFCLoginViewController.h"
#import "MFCLicenseManager.h"

@interface MFCLoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIView *logoCircle;
@property (nonatomic, strong) UILabel *logoLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UITextField *keyField;
@property (nonatomic, strong) UIButton *enterButton;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, assign) BOOL isValidating;

@end

@implementation MFCLoginViewController

#pragma mark - Ciclo de vida

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.keyField becomeFirstResponder];
}

#pragma mark - UI

- (void)setupUI {
    // Logo (círculo morado con "MFC")
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
    self.titleLabel.font = [UIFont systemFontOfSize:32 weight:UIFontWeightBold];
    self.titleLabel.textColor = [UIColor labelColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.titleLabel];

    // Subtítulo
    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.text = @"Introduce tu key de acceso";
    self.subtitleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    self.subtitleLabel.textColor = [UIColor secondaryLabelColor];
    self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.subtitleLabel];

    // Campo de key
    self.keyField = [[UITextField alloc] init];
    self.keyField.placeholder = @"XXXX-XXXX-XXXX-XXXX";
    self.keyField.borderStyle = UITextBorderStyleNone;
    self.keyField.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.keyField.layer.cornerRadius = 10;
    self.keyField.layer.borderWidth = 1;
    self.keyField.layer.borderColor = [UIColor separatorColor].CGColor;
    self.keyField.font = [UIFont monospacedSystemFontOfSize:16 weight:UIFontWeightMedium];
    self.keyField.textAlignment = NSTextAlignmentCenter;
    self.keyField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.keyField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.keyField.spellCheckingType = UITextSpellCheckingTypeNo;
    self.keyField.keyboardType = UIKeyboardTypeASCIICapable;
    self.keyField.returnKeyType = UIReturnKeyGo;
    self.keyField.delegate = self;
    self.keyField.translatesAutoresizingMaskIntoConstraints = NO;

    // Padding izquierdo al campo
    UIView *padding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
    self.keyField.leftView = padding;
    self.keyField.leftViewMode = UITextFieldViewModeAlways;

    [self.view addSubview:self.keyField];

    // Botón Entrar
    self.enterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.enterButton setTitle:@"ENTRAR" forState:UIControlStateNormal];
    [self.enterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.enterButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    self.enterButton.backgroundColor = [UIColor colorWithRed:0.5 green:0.2 blue:0.8 alpha:1.0];
    self.enterButton.layer.cornerRadius = 10;
    [self.enterButton addTarget:self action:@selector(onEnterTapped) forControlEvents:UIControlEventTouchUpInside];
    self.enterButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.enterButton];

    // Label de error
    self.errorLabel = [[UILabel alloc] init];
    self.errorLabel.text = @"";
    self.errorLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    self.errorLabel.textColor = [UIColor systemRedColor];
    self.errorLabel.textAlignment = NSTextAlignmentCenter;
    self.errorLabel.numberOfLines = 0;
    self.errorLabel.hidden = YES;
    self.errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.errorLabel];

    // Spinner
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.spinner.color = [UIColor whiteColor];
    self.spinner.hidesWhenStopped = YES;
    self.spinner.translatesAutoresizingMaskIntoConstraints = NO;
    [self.enterButton addSubview:self.spinner];

    // Layout
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        // Logo
        [self.logoCircle.topAnchor constraintEqualToAnchor:safe.topAnchor constant:60],
        [self.logoCircle.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor],
        [self.logoCircle.widthAnchor constraintEqualToConstant:100],
        [self.logoCircle.heightAnchor constraintEqualToConstant:100],
        [self.logoLabel.centerXAnchor constraintEqualToAnchor:self.logoCircle.centerXAnchor],
        [self.logoLabel.centerYAnchor constraintEqualToAnchor:self.logoCircle.centerYAnchor],

        // Título
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.logoCircle.bottomAnchor constant:24],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:24],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-24],

        // Subtítulo
        [self.subtitleLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:8],
        [self.subtitleLabel.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:24],
        [self.subtitleLabel.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-24],

        // Campo de key
        [self.keyField.topAnchor constraintEqualToAnchor:self.subtitleLabel.bottomAnchor constant:40],
        [self.keyField.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:30],
        [self.keyField.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-30],
        [self.keyField.heightAnchor constraintEqualToConstant:52],

        // Botón
        [self.enterButton.topAnchor constraintEqualToAnchor:self.keyField.bottomAnchor constant:16],
        [self.enterButton.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:30],
        [self.enterButton.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-30],
        [self.enterButton.heightAnchor constraintEqualToConstant:52],

        // Spinner dentro del botón
        [self.spinner.centerXAnchor constraintEqualToAnchor:self.enterButton.centerXAnchor],
        [self.spinner.centerYAnchor constraintEqualToAnchor:self.enterButton.centerYAnchor],

        // Error
        [self.errorLabel.topAnchor constraintEqualToAnchor:self.enterButton.bottomAnchor constant:16],
        [self.errorLabel.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:30],
        [self.errorLabel.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-30],
    ]];
}

#pragma mark - Acción Entrar

- (void)onEnterTapped {
    if (self.isValidating) return;

    NSString *key = [self.keyField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (key.length == 0) {
        [self showError:@"Introduce tu key"];
        return;
    }

    [self setLoading:YES];
    [self hideError];

    __weak typeof(self) weakSelf = self;

    [[MFCLicenseManager shared] validateKey:key completion:^(BOOL ok, NSString *errorMessage) {
        __strong typeof(self) self_ = weakSelf;
        if (!self_) return;

        [self_ setLoading:NO];

        if (ok) {
            // Login OK
            NSLog(@"[MFCLogin] Login OK");
            if (self_.onSuccess) {
                self_.onSuccess();
            }
        } else {
            [self_ showError:errorMessage ?: @"Error desconocido"];
        }
    }];
}

#pragma mark - Estados UI

- (void)setLoading:(BOOL)loading {
    self.isValidating = loading;
    self.enterButton.enabled = !loading;
    self.keyField.enabled = !loading;

    if (loading) {
        [self.enterButton setTitle:@"" forState:UIControlStateNormal];
        [self.spinner startAnimating];
    } else {
        [self.enterButton setTitle:@"ENTRAR" forState:UIControlStateNormal];
        [self.spinner stopAnimating];
    }
}

- (void)showError:(NSString *)message {
    self.errorLabel.text = message;
    self.errorLabel.hidden = NO;

    // Animación sutil de sacudida
    CAKeyframeAnimation *shake = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    shake.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    shake.duration = 0.4;
    shake.values = @[@(-8), @(8), @(-6), @(6), @(-3), @(3), @(0)];
    [self.keyField.layer addAnimation:shake forKey:@"shake"];
}

- (void)hideError {
    self.errorLabel.hidden = YES;
    self.errorLabel.text = @"";
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self onEnterTapped];
    return YES;
}

@end
