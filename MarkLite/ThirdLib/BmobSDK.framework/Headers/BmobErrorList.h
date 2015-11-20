//
//  BmobErrorList.h
//  BmobSDK
//
//  Created by Bmob on 15/4/13.
//  Copyright (c) 2015年 Bmob. All rights reserved.
//

#ifndef BmobSDK_BmobErrorList_h
#define BmobSDK_BmobErrorList_h


typedef enum {
    BmobErrorTypeNullPassword        = 20000, //登录或者注册时输入的密码为空。
    BmobErrorTypeNullUsername        = 20001, //登录或者注册时输入的用户名为空。
    BmobErrorTypeConnectFailed       = 20002, //connect failed!
    BmobErrorTypeNullObjectId        = 20003, //更新对象、删除对象、查询单个对象时没有objectid
    BmobErrorTypeNullObject          = 20004, //查询时，查询结果为空
    BmobErrorTypeQueryCachedExpired  = 20005, //缓存查询时，查询时间已过期
    BmobErrorTypeCloudFunctionFailed = 20006, //云端代码调用失败
    BmobErrorTypeNullFilename        = 20008, //上传文件时，文件名为空
    BmobErrorTypeNullFileUrl         = 20009, //删除文件时，文件的url为空
    BmobErrorTypeUnknownError        = 20010, //未知错误
    BmobErrorTypeNullFileData        = 20011, //上传文件时，文件内容为空
    BmobErrorTypeNullUpdateContent   = 20012, //更新时，更新内容为空
    BmobErrorTypeNullFunctionName    = 20013, //调用云端代码时，函数名为空
    BmobErrorTypeArraySizeLarge      = 20014, //批量操作时，传入的数组超过界限
    BmobErrorTypeNullArray           = 20015, //批量操作时，传入的数组为空
    BmobErrorTypeNullPushContent     = 20016, //推送时，推送内容为空
    BmobErrorTypeFileSizeLimited     = 20017, //上传文件时，文件大小超出限制
    BmobErrorTypeLackOfInfomation    = 20020, //第三方登录、关联时缺乏必要的信息
    BmobErrorTypeErrorType           = 20021, //类型错误
    BmobErrorTypeInitNotFinish       = 20022, //初始化未完成
    BmobErrorTypeInitFailed          = 20023, //初始化失败
    BmobErrorTypeErrorFormat         = 20024, //批量文件上传时格式错误
    BmobErrorTypeNullClassName       = 20025,  //表名为空
    BmobErrorTypeNullBlock           = 20026,  //异步查询时，没有传入block，无法返回结果
    BmobErrorTypeErrorPara           = 20027,  //传的参数有错，一般是传入空字符串造成
    BmobErrorTypeInvalidMobilePhoneNumber = 20028,  //非法手机号
    BmobErrorTypeInvalidSMSCode      = 20029,   //非法验证码
    BmobErrorTypeFileNotExist        = 20030   //获取文件url、删除文件时传入的文件名不存在
    
}BmobErrorType;



#endif
