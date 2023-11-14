import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class Usuario {
  late String nome;
  late String email;
  late String cpf;
  late String status;
  Usuario(
    {required this.nome,
    required this.email,
    required this.cpf,
    this.status = "v"}
  );

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'status': status
    };
  }

  String toJson() => json.encode(toMap());
}

class UserDataService {
  final ValueNotifier<List<Usuario>> _userListNotifier = ValueNotifier<List<Usuario>>([]);
  ValueNotifier<List<Usuario>> get userListNotifier => _userListNotifier;
  
  List<Usuario> listaUsers =[];
  Future<List<Usuario>> loadUsers() async {
    Directory directory = await getApplicationSupportDirectory();
    File file = File('${directory.path}/users.dat');

    if (file.existsSync()) {
      String content = await file.readAsString();
      if (content != '') {
        List<dynamic> jsonList = json.decode(content);
        List<Usuario> userList = jsonList.map((json) => Usuario(
          nome: json['nome'],
          email: json['email'],
          cpf: json['cpf'],
          status: json['status'],
        )).toList();
        _userListNotifier.value = userList;
        return _userListNotifier.value;
      }
    }

    return _userListNotifier.value;
  }

  carregar() async{
    listaUsers = await userDataService.loadUsers();
    print(listaUsers);
  }
  Future<void> carregarUsuarios() async {
    listaUsers = await userDataService.loadUsers();
  }


  Future<void> saveUsers(List<Usuario> users) async {
    Directory directory = await getApplicationSupportDirectory();
    File file = File('${directory.path}/users.dat');
    String content = json.encode(users.map((user) => user.toMap()).toList());
    await file.writeAsString(content);
  }

  void deleteUser(Usuario user) {
    user.status = 'x';
    saveUsers(listaUsers);
    carregarUsuarios();
  }

  void atualizarUsuario(int index, Usuario novoUsuario) {
    listaUsers[index] = novoUsuario;
    userDataService.saveUsers(listaUsers);
    carregarUsuarios();
  }
}

final UserDataService userDataService = UserDataService();
