import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

enum TableStatus{idle,loading,ready,error}

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

  final ValueNotifier<Map<String,dynamic>> usersStateNotifier = 
    ValueNotifier({
      'status':TableStatus.idle,
      'dataObjects':[],
    }
  );
  bool isSorted = false;

  List<Usuario> listaOriginal =[];
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
        return userList;
      }
    }

    return _userListNotifier.value;
  }


  void carregarUsuarios() async {
    var json = await loadUsers();
    usersStateNotifier.value = {
      'status':TableStatus.ready,
      'dataObjects': json
    };
    listaOriginal = json;
  }


  Future<void> saveUsers(List<Usuario> users) async {
    Directory directory = await getApplicationSupportDirectory();
    File file = File('${directory.path}/users.dat');
    String content = json.encode(users.map((user) => user.toMap()).toList());
    await file.writeAsString(content);
  }

  void criarUser(Usuario newUser){
    usersStateNotifier.value['dataObjects'] = [...usersStateNotifier.value['dataObjects'], newUser];
    usersStateNotifier.value['dataObjects'] = List<Usuario>.from(usersStateNotifier.value['dataObjects']);

    saveUsers(usersStateNotifier.value['dataObjects']);
    carregarUsuarios();
  }

  void deleteUser(Usuario user) {
    user.status = 'x';
    saveUsers(usersStateNotifier.value['dataObjects']);
    carregarUsuarios();
  }

  void atualizarUsuario({
    required List<Usuario> listaUsers,
    required int index,
    required Usuario novoUsuario,
  }) {

    listaUsers[index] = novoUsuario;

    userDataService.saveUsers(listaUsers);
    carregarUsuarios();
  }

  void filtrarEstadoAtual(String filtrar) {
    List<Usuario> objetosOriginais = listaOriginal;
    if (objetosOriginais.isEmpty) return;

    List<Usuario> objetosFiltrados = [];
    if (filtrar != '') {
      for (var objetoInd in objetosOriginais) {
        if (objetoInd.nome.toLowerCase().contains(filtrar.toLowerCase())) {
          objetosFiltrados.add(objetoInd);
        }
      }
    } else {
      objetosFiltrados = objetosOriginais;
    }
    

    emitirEstadoFiltrado(objetosFiltrados);
  }

  void emitirEstadoFiltrado(List<Usuario> objetosFiltrados) {
    var estado = Map<String, dynamic>.from(usersStateNotifier.value);
    estado['dataObjects'] = objetosFiltrados;
    usersStateNotifier.value = estado;
  }

  ordenar(){
    var estado = Map<String, dynamic>.from(usersStateNotifier.value);

    if (!isSorted){
      estado['dataObjects'].sort((Usuario a, Usuario b) => a.nome.compareTo(b.nome));
      usersStateNotifier.value = estado;
      isSorted= true;
    } 
    else{
      estado['dataObjects'] = List.from(estado['dataObjects'].reversed);
      usersStateNotifier.value = estado;
    }
  }
  
  

}

final UserDataService userDataService = UserDataService();
