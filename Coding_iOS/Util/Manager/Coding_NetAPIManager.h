//
//  Coding_NetAPIManager.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-30.
//  Copyright (c) 2014年 Coding. All rights reserved.
//


#import "CodingNetAPIClient.h"

#import "Tweets.h"
#import "Users.h"
#import "PrivateMessages.h"


#import "CodingTips.h"
#import "Login.h"

@class CSTopic;

typedef NS_ENUM(NSUInteger, VerifyType){
    VerifyTypeUnknow = 0,
    VerifyTypePassword,
    VerifyTypeTotp,
};

@interface Coding_NetAPIManager : NSObject
+ (instancetype)sharedManager;

//UnRead
- (void)request_UnReadCountWithBlock:(void (^)(id data, NSError *error))block;
- (void)request_UnReadNotificationsWithBlock:(void (^)(id data, NSError *error))block;


//Login
- (void)request_Login_With2FA:(NSString *)otpCode andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Login_WithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Register_WithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_CaptchaNeededWithPath:(NSString *)path andBlock:(void (^)(id data, NSError *error))block;
- (void)request_SendMailToPath:(NSString *)path email:(NSString *)email j_captcha:(NSString *)j_captcha andBlock:(void (^)(id data, NSError *error))block;
- (void)request_SetPasswordToPath:(NSString *)path params:(NSDictionary *)params andBlock:(void (^)(id data, NSError *error))block;




//Tweet
- (void)request_Tweets_WithObj:(Tweets *)tweets andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_DoLike_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_DoComment_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_DoTweet_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_Likers_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_Comments_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_Delete_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_TweetComment_Delete_WithTweet:(Tweet *)tweet andComment:(Comment *)comment andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_Detail_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_PublicTweetsWithTopic:(NSInteger)topicID andBlock:(void (^)(id data, NSError *error))block;


//User
- (void)request_UserInfo_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ResetPassword_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block;
- (void)request_FollowersOrFriends_WithObj:(Users *)curUsers andBlock:(void (^)(id data, NSError *error))block;
- (void)request_FollowedOrNot_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block;
- (void)request_UserJobArrayWithBlock:(void (^)(id data, NSError *error))block;
- (void)request_UserTagArrayWithBlock:(void (^)(id data, NSError *error))block;
- (void)request_UpdateUserInfo_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block;


//Message
- (void)request_PrivateMessages:(PrivateMessages *)priMsgs andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Fresh_PrivateMessages:(PrivateMessages *)priMsgs andBlock:(void (^)(id data, NSError *error))block;
- (void)request_SendPrivateMessage:(PrivateMessage *)nextMsg andBlock:(void (^)(id data, NSError *error))block;
- (void)request_SendPrivateMessage:(PrivateMessage *)nextMsg andBlock:(void (^)(id data, NSError *error))block progerssBlock:(void (^)(CGFloat progressValue))progress;
- (void)request_playedPrivateMessage:(PrivateMessage *)pm;
- (void)request_CodingTips:(CodingTips *)curTips andBlock:(void (^)(id data, NSError *error))block;
- (void)request_markReadWithCodingTips:(CodingTips *)curTips andBlock:(void (^)(id data, NSError *error))block;
- (void)request_markReadWithCodingTipIdStr:(NSString *)tipIdStr andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeletePrivateMessage:(PrivateMessage *)curMsg andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeletePrivateMessagesWithObj:(PrivateMessage *)curObj andBlock:(void (^)(id data, NSError *error))block;


//Image
- (void)uploadTweetImage:(UIImage *)image
               doneBlock:(void (^)(NSString *imagePath, NSError *error))done
              progerssBlock:(void (^)(CGFloat progressValue))progress;

- (void)request_UpdateUserIconImage:(UIImage *)image
                       successBlock:(void (^)(id responseObj))success
                       failureBlock:(void (^)(NSError *error))failure
                      progerssBlock:(void (^)(CGFloat progressValue))progress;
- (void)loadImageWithPath:(NSString *)imageUrlStr completeBlock:(void (^)(UIImage *image, NSError *error))block;

//Other
- (void)request_Users_WithSearchString:(NSString *)searchStr andBlock:(void (^)(id data, NSError *error))block;

- (void)request_VerifyTypeWithBlock:(void (^)(VerifyType type, NSError *error))block;

- (void)request_Users_WithTopicID:(NSInteger)topicID andBlock:(void (^)(id data, NSError *error))block;
- (void)request_JoinedUsers_WithTopicID:(NSInteger)topicID page:(NSInteger)page andBlock:(void (^)(id data, NSError *error))block;


//Topic HotKey
- (void)request_TopicHotkeyWithBlock:(void (^)(id data, NSError *error))block;
//Topic
- (void)request_TopicAdlistWithBlock:(void (^)(id data, NSError *error))block;
- (void)request_HotTopiclistWithBlock:(void (^)(id data, NSError *error))block;

- (void)request_Tweet_WithSearchString:(NSString *)strSearch andPage:(NSInteger)page andBlock:(void (^)(id data, NSError *error))block;

- (void)request_TopicDetailsWithTopicID:(NSInteger)topicID block:(void (^)(id data, NSError *error))block;
- (void)request_TopTweetWithTopicID:(NSInteger)topicID block:(void (^)(id data, NSError *error))block;

- (void)request_JoinedTopicsWithUserGK:(NSString *)userGK page:(NSInteger)page block:(void (^)(id data, BOOL hasMoreData, NSError *error))block;
- (void)request_WatchedTopicsWithUserGK:(NSString *)userGK page:(NSInteger)page block:(void (^)(id data, BOOL hasMoreData, NSError *error))block;

- (void)request_Topic_DoWatch_WithUrl:(NSString *)url andBlock:(void (^)(id data, NSError *error))block;
- (void)request_BannersWithBlock:(void (^)(id data, NSError *error))block;

@end
