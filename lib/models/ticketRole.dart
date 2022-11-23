class TicketRole {
  late String id;
  late String name;

  TicketRole();

  TicketRole.fromMap(Map map){
    id = map['id'];
    name = map['name'];
  }
}