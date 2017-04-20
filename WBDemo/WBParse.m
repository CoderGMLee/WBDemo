//
//  WBParse.m
//  WBDemo
//
//  Created by GM on 17/2/17.
//  Copyright © 2017年 GM. All rights reserved.
//

#import "WBParse.h"
#import "CommonHeader.h"
#import <SVProgressHUD.h>
@interface WBParse () <NSXMLParserDelegate>
@property (nonatomic, strong) WBControlModel * curControlModel;
@property (nonatomic, strong) WBBaseObject * curSubModel;
@property (nonatomic, copy) NSString * curProperty;
@property (nonatomic, copy) NSString * curPropertyName;
@property (nonatomic, copy) NSString * curImagePropertyName;
@end

@implementation WBParse

+ (WBParse *)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WBParse alloc] init];
    });
    return sharedInstance;
}

+ (void)parse {

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"download" ofType:@"xml"];
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:filePath];
    [self parseWithData:xmlData];

}

+ (void)parseWithData:(NSData *)data {

    [[WBModelManager sharedInstance] clearAll];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:data  options:0 error:nil];

    GDataXMLElement *rootElement = [doc rootElement];

    //Document_Element
    for (GDataXMLElement * element in rootElement.children) {
        //Controller
        for (GDataXMLElement * objElement in element.children) {
            [[WBParse sharedInstance] parseCotrolleElement:objElement];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotiParseComplete object:nil];
}

//解析control
- (WBControlModel *)parseCotrolleElement:(GDataXMLElement *)element {
    NSString * name = [element attributeForName:@"class"].stringValue;
    if (![name isEqualToString:KElementControl]) {
        return nil;
    }
    WBControlModel * controlModel = [[WBControlModel alloc] init];
    [self setCommonAttribute:controlModel withElement:element];
    [[WBModelManager sharedInstance] addControllerModel:controlModel];

    //解析ZiUserControl
    NSArray * propertyArray = [element elementsForName:KNodeProperty];
    NSArray * objectArray = [element elementsForName:KNodeObject];

    //设置Property
    for (NSInteger index = 0; index < propertyArray.count; index ++) {
        GDataXMLElement * propertyElement = propertyArray[index];
        NSString * value = propertyElement.stringValue;
        NSString * name = [propertyElement attributeForName:@"name"].stringValue;
        if ([name containsString:@"Image"]) {
            NSString * binaryStr = [[propertyElement elementsForName:@"Binary"][0] stringValue];
            NSData *decodedData = nil;
            if (binaryStr) {
                decodedData = [[NSData alloc] initWithBase64EncodedString:binaryStr options:0];
            }
            if (decodedData) {
                [controlModel setValue:decodedData forKey:name];
            }
        } else {
            [controlModel setValue:value forKey:name];
        }
    }

    //设置Object 元素
    for (GDataXMLElement * objElement in objectArray) {
        WBBaseObject * baseModel = [self parseBaseElement:objElement];
        if (baseModel) {
            [controlModel.subModels addObject:baseModel];
        } else {
            NSLog(@"baseModel can not be nil");
        }

    }
    return controlModel;
}

- (WBBaseObject *)parseBaseElement:(GDataXMLElement *)element {
    WBBaseObject * baseModel = nil;
    NSString * name = [element attributeForName:@"class"].stringValue;
    if ([name isEqualToString:KElementButton]) {
        //解析Button
        baseModel = [self parseButtonElement:element];
    } else if ([name isEqualToString:KElementImageView]) {
        //解析ImageView
        baseModel = [self parseImageView:element];
    } else if ([name isEqualToString:KElementTextView]) {
        //解析TextView
        baseModel = [self parseTextView:element];
    }
    return baseModel;
}

- (WBButtonModel *)parseButtonElement:(GDataXMLElement *)element {
    NSString * name = [element attributeForName:@"class"].stringValue;
    if (![name isEqualToString:KElementButton]) {
        return nil;
    }

    WBButtonModel * buttonModel = [[WBButtonModel alloc] init];
    [self setCommonAttribute:buttonModel withElement:element];
    [self setPropertyFor:buttonModel with:element];
    return buttonModel;
}

- (WBImageViewModel *)parseImageView:(GDataXMLElement *)element {

    NSString * name = [element attributeForName:@"class"].stringValue;
    if (![name isEqualToString:KElementImageView]) {
        return nil;
    }

    WBImageViewModel * imageModel = [[WBImageViewModel alloc] init];
    [self setCommonAttribute:imageModel withElement:element];
    [self setPropertyFor:imageModel with:element];
    return imageModel;
}

- (WBTextViewModel *)parseTextView:(GDataXMLElement *)element {

    NSString * name = [element attributeForName:@"class"].stringValue;
    if (![name isEqualToString:KElementTextView]) {
        return nil;
    }

    WBTextViewModel * textModel = [[WBTextViewModel alloc] init];
    [self setCommonAttribute:textModel withElement:element];
    [self setPropertyFor:textModel with:element];
    return textModel;
}

- (void)setCommonAttribute:(WBBaseObject *)baseModel withElement:(GDataXMLElement *)element{
    baseModel.type = [element attributeForName:@"type"].stringValue;
    baseModel.className = [element attributeForName:@"class"].stringValue;
    baseModel.name = [element attributeForName:@"name"].stringValue;
    baseModel.children = [element attributeForName:@"children"].stringValue;
}

- (WBBaseObject *)setPropertyFor:(WBBaseObject *)baseObject with:(GDataXMLElement *)element {

    if (!baseObject) {
        baseObject = [[WBBaseObject alloc] init];
    }
    NSArray * propertyArray = [element elementsForName:KNodeProperty];
    for (GDataXMLElement * element in propertyArray) {
        NSLog(@"name : %@",[element attributeForName:@"name"].stringValue);
    }
    for (NSInteger index = 0; index < propertyArray.count; index ++) {
        GDataXMLElement * propertyElement = propertyArray[index];
        NSString * value = propertyElement.stringValue;
        NSString * name = [propertyElement attributeForName:@"name"].stringValue;
        if ([name containsString:@"Image"]) {
            NSString * binaryStr = [[propertyElement elementsForName:@"Binary"][0] stringValue];
            NSData *decodedData = nil;
            if (binaryStr) {
                decodedData = [[NSData alloc] initWithBase64EncodedString:binaryStr options:0];
            }
            if (decodedData) {
                if ([baseObject respondsToSelector:NSSelectorFromString(name)]) {
                    [baseObject setValue:decodedData forKey:name];
                }
            }
        } else {
            [baseObject setValue:value forKey:name];
        }
    }
    return baseObject;
}



#pragma mark - NSXMLParserDelegate


- (void)parse {
    NSString * resourcePath = @"/Users/liguomin/Desktop/wbProject/捷思通IOS测试/test.xml";
//    NSString * resourcePath = @"/Users/liguomin/Desktop/wbProject/download.xml";
///Users/liguomin/Desktop/wbProject/捷思通IOS测试/test.xml
    NSData * data = [[NSData alloc] initWithContentsOfFile:resourcePath];
    [self parseWithData:data];
}

- (void)parseWithData:(NSData *)data {
    
    NSXMLParser * parse = [[NSXMLParser alloc] initWithData:data];
    parse.delegate = self;
    [parse parse];
}

//解析开始
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"\n=====================解析开始=====================");
}


// 发现节点时
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
//    NSLog(@"elementName : %@ namespaceURI : %@ qualifiedName : %@ attributes : %@",elementName,namespaceURI,qName,attributeDict);
    self.curProperty = elementName;
    if ([self.curProperty isEqualToString:@"Property"]) {
        self.curPropertyName = attributeDict[@"name"];
    }

    NSString * attribeteClass = attributeDict[@"class"];

    if ([elementName isEqualToString:@"Object"]){
        if (self.curControlModel == nil && [attribeteClass isEqualToString:@"ZiUserControl"]) {
            self.curControlModel = [[WBControlModel alloc] init];
            [self setPropertyForModel:self.curControlModel withAttributes:attributeDict];
        } else {
            if ([attribeteClass isEqualToString:@"ZiTextView"]) {
                self.curSubModel = [[WBTextViewModel alloc] init];
            } else if ([attribeteClass isEqualToString:@"ZiButton"]) {
                self.curSubModel = [[WBButtonModel alloc] init];
            } else {
                self.curSubModel = [[WBImageViewModel alloc] init];
            }
            [self setPropertyForModel:self.curSubModel withAttributes:attributeDict];
        }
    }
}

//发现节点值时
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {

    if ( ([self.curProperty isEqualToString:@"Property"] && ![string containsString:@"\n"]) || [self.curProperty isEqualToString:@"Binary"] ) {
        if (self.curSubModel == nil) {
            [self setPropertyForModel:self.curControlModel withKey:self.curPropertyName value:string];
        } else {
            [self setPropertyForModel:self.curSubModel withKey:self.curPropertyName value:string];
        }
    }
}

// 结束节点时
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {

    if ([elementName isEqualToString:@"Object"]) {
        if (self.curSubModel == nil) {
            [[WBModelManager sharedInstance] addControllerModel:self.curControlModel];
            self.curControlModel = nil;
        } else {
            [self.curControlModel.subModels addObject:self.curSubModel];
            self.curSubModel = nil;
        }
    }
}

//解析结束
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"\n=====================解析结束=====================");
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotiParseComplete object:nil];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"NSXML ERROR： %@",parseError);
    [SVProgressHUD showInfoWithStatus:@"解析失败"];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotiParseError object:nil];
}

- (void)setPropertyForModel:(WBBaseObject *)baseModel withAttributes:(NSDictionary *)attributes{
    for (NSString * key in attributes.allKeys) {
        [self setPropertyForModel:baseModel withKey:key value:attributes[key]];
    }
}

- (void)setPropertyForModel:(WBBaseObject *)baseModel withKey:(NSString *)key value:(NSString *)value {
    if ([baseModel respondsToSelector:NSSelectorFromString(key)]) {
        if ([key containsString:@"Image"]) {
            NSData *decodedData = nil;
            if (value) {
                decodedData = [[NSData alloc] initWithBase64EncodedString:value options:0];
            }
            if (decodedData) {
                [baseModel setValue:decodedData forKey:self.curPropertyName];
            }
        } else if ([key isEqualToString:@"class"]){
            [baseModel setValue:value forKey:@"className"];
        } else {
            [baseModel setValue:value forKey:key];
        }
    }
}


@end
