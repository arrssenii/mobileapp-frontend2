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
    if (!_isValidPhone(event.phone)) {
      // Или _isValidLogin, если используете логин
      emit(
        LoginError(message: 'Неверный формат телефона/логина'),
      ); // Уточните сообщение
      return;
    }
    emit(LoginLoading());
    try {
      final user = await loginUseCase(
        event.phone,
        event.password,
      ); // phone или login
      emit(LoginSuccess(user: user, userId: user.userId));
    } on ApiError catch (e) {
      // Ловим ApiError, созданный в ApiClient
      emit(
        LoginError(message: e.message ?? 'Ошибка авторизации'),
      ); // Используем сообщение из ApiError
    } on DioException catch (e) {
      // Ловим DioException напрямую, если ApiClient её не обернул
      String errorMessage = 'Ошибка сети';
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Таймаут соединения';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Нет подключения к интернету';
      }
      emit(LoginError(message: errorMessage));
    } catch (e) {
      emit(LoginError(message: 'Неизвестная ошибка: ${e.toString()}'));
    }
  }
}

bool _isValidPhone(String phone) {
  return RegExp(r'^\+7\d{10}$').hasMatch(phone);
}
