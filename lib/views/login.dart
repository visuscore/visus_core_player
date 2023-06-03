import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:validatorless/validatorless.dart';
import 'package:visus_core_player/constants/route_names.dart';
import 'package:visus_core_player/controllers/login_controller.dart';
import 'package:visus_core_player/extensions/build_context_extensions.dart';
import 'package:visus_core_player/extensions/theme_extensions.dart';
import 'package:visus_core_player/infrastructure/services/i_authentication_service.dart';
import 'package:visus_core_player/infrastructure/services/i_credentials_accessor.dart';
import 'package:visus_core_player/infrastructure/services/i_host_accessor.dart';
import 'package:visus_core_player/services/navigator_service.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();

    _animation =
        CurvedAnimation(parent: _animationController!, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _animationController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<LoginController>(
            create: (context) => LoginController(
              context.read<IAuthenticationService>(),
              context.read<ICredentialsAccessor>(),
              context.read<IHostAccessor>(),
            ),
          ),
        ],
        builder: (context, child) {
          return Scaffold(
              body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/traffic.jpg'),
                colorFilter: ColorFilter.mode(
                  context.cardColor.withOpacity(0.5),
                  BlendMode.dstATop,
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Center(
                  child: FadeTransition(
                    opacity: _animation!,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: context.paddingBottom,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 600),
                              child: Card(
                                child: Padding(
                                  padding: context.paddingAll,
                                  child: Form(
                                    key:
                                        context.read<LoginController>().formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                            padding: context.paddingBottom,
                                            child: SvgPicture.asset(
                                              'assets/logo.svg',
                                              height: 64,
                                            )),
                                        const Text(
                                            'Please sign in to continue'),
                                        TypeAheadFormField(
                                          onSuggestionSelected:
                                              (String suggestion) {
                                            context
                                                .read<LoginController>()
                                                .hostController
                                                .text = suggestion;
                                          },
                                          itemBuilder:
                                              (context, String suggestion) {
                                            return ListTile(
                                              title: Text(suggestion),
                                            );
                                          },
                                          suggestionsCallback: (pattern) =>
                                              context
                                                  .read<LoginController>()
                                                  .filterHostList(pattern),
                                          textFieldConfiguration:
                                              TextFieldConfiguration(
                                            controller: context
                                                .read<LoginController>()
                                                .hostController,
                                            decoration: const InputDecoration(
                                              labelText: 'Host',
                                            ),
                                          ),
                                          validator: Validatorless.multiple([
                                            Validatorless.required(
                                                'Host is required'),
                                          ]),
                                        ),
                                        TextFormField(
                                            controller: context
                                                .read<LoginController>()
                                                .emailController,
                                            decoration: const InputDecoration(
                                              labelText: 'Email',
                                            ),
                                            validator: Validatorless.multiple([
                                              Validatorless.required(
                                                  'Email is required'),
                                            ])),
                                        Padding(
                                            padding: context.paddingBottom,
                                            child: TextFormField(
                                              controller: context
                                                  .read<LoginController>()
                                                  .passwordController,
                                              decoration: InputDecoration(
                                                  labelText: 'Password',
                                                  suffixIcon: IconButton(
                                                    onPressed: () => setState(
                                                        () => context
                                                            .read<
                                                                LoginController>()
                                                            .togglePasswordVisibility()),
                                                    icon: context
                                                            .read<
                                                                LoginController>()
                                                            .isPasswordVisible
                                                        ? const Icon(
                                                            Icons.visibility)
                                                        : const Icon(Icons
                                                            .visibility_off),
                                                  )),
                                              obscureText: !context
                                                  .read<LoginController>()
                                                  .isPasswordVisible,
                                              validator:
                                                  Validatorless.multiple([
                                                Validatorless.required(
                                                    'Password is required'),
                                              ]),
                                            )),
                                        FilledButton(
                                          statesController: context
                                              .read<LoginController>()
                                              .signInController,
                                          onPressed: () async => await context
                                              .read<LoginController>()
                                              .login(),
                                          child: const Text('Sign in'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: context.paddingBottom,
                            child: GestureDetector(
                              onTap: () => context
                                  .read<NavigatorService>()
                                  .pushNamed(RouteNames.forgotPassword),
                              child: Text(
                                'Can\'t log in?',
                                style: context.textTheme.labelLarge?.copyWith(
                                  color: context.hintColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: context.paddingBottom,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: context.textTheme.labelLarge?.copyWith(
                                    color: context.hintColor,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context
                                      .read<NavigatorService>()
                                      .pushNamed(RouteNames.signUp),
                                  child: Text(
                                    "Sign up",
                                    style:
                                        context.textTheme.labelLarge?.copyWith(
                                      color: context.hintColor,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
          ));
        });
  }
}
