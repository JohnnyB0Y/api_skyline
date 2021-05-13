//  api_keys.dart
//
//
//  Created by JohnnyB0Y on 2020/5/11.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//  

class RMK {
  RMK._();
  
  /// 标题文本 👉 String
  static const String title = 'rmk_' + 'title';
  /// 子标题文本 👉 String
  static const String subtitle = 'rmk_' + 'subtitle';
  /// 详情文本 👉 String
  static const String detail = 'rmk_' + 'detail';
  /// 描述文本 👉 String
  static const String desc = 'rmk_' + 'desc';
  /// 占位文本 👉 String
  static const String hintText = 'rmk_' + 'hitText';
  /// 输入文本 👉 String
  static const String text = 'rmk_' + 'text';
  /// url字符串 👉 String
  static const String url = 'rmk_' + 'url';


  /// 国际化 - 取值函数Key 👉 func
  static const String i18nGetterFunc = 'rmk_' + 'i18nGetterFunc';
  /// 国际化 - 默认字符串Key 👉 i18n
  static const String i18n = 'rmk_' + 'i18n';
  

  /// 左上方按钮标题 👉 String
  static const String topLeftBtnTitle = 'rmk_' + 'topLeftBtnTitle';
  /// 中上方按钮标题 👉 String
  static const String topCenterBtnTitle = 'rmk_' + 'topCenterBtnTitle';
  /// 右上方按钮标题 👉 String
  static const String topRightBtnTitle = 'rmk_' + 'topRightBtnTitle';
  /// 左中方按钮标题 👉 String
  static const String centerLeftBtnTitle = 'rmk_' + 'centerLeftBtnTitle';
  /// 正中间按钮标题 👉 String
  static const String centerBtnTitle = 'rmk_' + 'centerBtnTitle';
  /// 右中方按钮标题 👉 String
  static const String centerRightBtnTitle = 'rmk_' + 'centerRightBtnTitle';
  /// 左下方按钮标题 👉 String
  static const String bottomLeftBtnTitle = 'rmk_' + 'bottomLeftBtnTitle';
  /// 中下方按钮标题 👉 String
  static const String bottomCenterBtnTitle = 'rmk_' + 'bottomCenterBtnTitle';
  /// 右下方按钮标题 👉 String
  static const String bottomRightBtnTitle = 'rmk_' + 'bottomRightBtnTitle';


// TODO ----------------------- 图片相关
  /// icon图标 👉 IconData
  static const String iconData = 'rmk_' + 'iconData';
  /// 选中的文件对象 👉 PickedFile
  static const String pickedFile = 'rmk_' + 'pickedFile';
  /// 图片网络地址 👉 String
  static const String imageUrl = 'rmk_' + 'imageUrl';
  ///< 是否已上传图片？ 👉 bool
  static const String didUploadImage = 'rmk_' + 'didUploadImage';


  /// 位置 👉 int
  static const String index = 'rmk_' + 'index';
  /// ID 👉 int
  static const String id = 'rmk_' + 'id';
  /// 最大行数 👉 int
  static const String maxLines = 'rmk_' + 'maxLines';
  /// 最小行数 👉 int
  static const String minLines = 'rmk_' + 'minLines';
  /// 最小长度 👉 int
  static const String minLength = 'rmk_' + 'minLength';
  /// 最大长度 👉 int
  static const String maxLength = 'rmk_' + 'maxLength';



  ///< 是否选中状态？ 👉 bool
  static const String selected = 'rmk_' + 'selected';
  ///< 是否禁用状态？ 👉 bool
  static const String disabled = 'rmk_' + 'disabled';
  ///< 是否删除状态？ 👉 bool
  static const String deleted = 'rmk_' + 'deleted';
  ///< 是否添加状态？ 👉 bool
  static const String added = 'rmk_' + 'added';
  ///< 是否显示状态？ 👉 bool
  static const String showed = 'rmk_' + 'showed';
  ///< 是否打开状态？ 👉 bool
  static const String opened = 'rmk_' + 'opened';
  ///< 是否关闭状态？ 👉 bool
  static const String closed = 'rmk_' + 'closed';
  ///< 是否编辑状态？ 👉 bool
  static const String edited = 'rmk_' + 'edited';
  ///< 是否自动聚焦？ 👉 bool
  static const String autofocus = 'rmk_' + 'autofocus';


  ///< Widget的Key 👉 Key
  static const String widgetKey = 'rmk_' + 'widgetKey';

  ///< List<ReactModel> 👉 List<ReactModel>
  static const String reactModels = 'rmk_' + 'reactModels';

  ///< 暗号 👉 Sting
  static const String cipher = 'rmk_' + 'cipher';

  ///< 区分 item 的类型 👉 int
  static const String itemType = 'rmk_' + 'itemType';

  ///< 区分 item 的类型 👉 RMUserInteractionType
  static const String interactionType = 'rmk_' + 'interactionType';

  /// 投稿情况：审核中；审核通过；审核不通过； 👉 int
  static const String submitStatus = 'rmk_' + 'submitStatus';

}


/// 通知名
class RMNoticeName {
  ///< item被点击
  static const String itemClick = 'RMNoticeName_' + 'itemClick';

  ///< 选中按钮被点击
  static const String selectClick = 'RMNoticeName_' + 'selectClick';

  ///< 更多按钮被点击
  static const String moreClick = 'RMNoticeName_' + 'moreClick';

  ///< 编辑按钮被点击
  static const String editClick = 'RMNoticeName_' + 'editClick';

  ///< 查看详情按钮被点击
  static const String detailClick = 'RMNoticeName_' + 'detailClick';

  ///< 同意按钮被点击
  static const String agreeClick = 'RMNoticeName_' + 'agreeClick';

  ///< 拒绝按钮被点击
  static const String rejectClick = 'RMNoticeName_' + 'rejectClick';

  /// 打开链接
  static const String openUrl = 'RMNoticeName_' + 'openUrl';

  /// 选择
  static const String choose = 'RMNoticeName_' + 'choose';

  /// 移除
  static const String remove = 'RMNoticeName_' + 'remove';

}


/// 用户交互类型
enum RMUserInteractionType {
  /// 普通模式
  normal,
  // 编辑模式
  edit,
  /// 选择模式
  select,
  /// 单选
  choose,
}
