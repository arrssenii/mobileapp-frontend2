import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/login_usecase.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;

  LoginBloc({required this.loginUseCase}) : super(LoginInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(
  LoginRequested event,
  Emitter<LoginState> emit,
) async {
  emit(LoginLoading());
  try {
    final user = await loginUseCase(event.username, event.password);
    emit(LoginSuccess(user: user));
  } on ApiError catch (e) {
    emit(LoginError(message: e.message));
  } on DioException catch (e) {
    emit(LoginError(message: e.message ?? 'Ошибка сети'));
  } catch (e) {
    emit(LoginError(message: 'Неизвестная ошибка: ${e.toString()}'));
  }
}
}