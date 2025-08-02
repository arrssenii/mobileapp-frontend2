part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends LoginEvent {
  final String phone;
  final String password;

  const LoginRequested(this.phone, this.password);

  @override
  List<Object> get props => [phone, password];
}