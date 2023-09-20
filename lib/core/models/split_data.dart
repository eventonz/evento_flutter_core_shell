class SplitDataM {
  List<ItemsWrapper>? itemsWrapper;

  SplitDataM({this.itemsWrapper});

  SplitDataM.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      itemsWrapper = <ItemsWrapper>[];
      json['items'].forEach((v) {
        itemsWrapper!.add(ItemsWrapper.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (itemsWrapper != null) {
      data['items'] = itemsWrapper!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ItemsWrapper {
  List<Items>? items;
  String? type;
  String? result;
  List<Entries>? entries;

  ItemsWrapper({this.items, this.type, this.result, this.entries});

  ItemsWrapper.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    type = json['type'];
    result = json['result'];
    if (json['entries'] != null) {
      entries = <Entries>[];
      json['entries'].forEach((v) {
        entries!.add(Entries.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    data['type'] = type;
    data['result'] = result;
    if (entries != null) {
      data['entries'] = entries!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Items {
  String? name;
  String? value;

  Items({this.name, this.value});

  Items.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['value'] = value;
    return data;
  }
}

class Entries {
  List<String>? data;
  String? style;

  Entries({this.data, this.style});

  Entries.fromJson(Map<String, dynamic> json) {
    data = json['data'].cast<String>();
    style = json['style'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data;
    data['style'] = style;
    return data;
  }
}
