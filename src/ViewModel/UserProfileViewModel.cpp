#include "UserProfileViewModel.h"
#include "Service/NeteaseCloudMusic/Response/LoginStatusEntity.h"
#include <Service/NeteaseCloudMusic/CloudMusicClient.h>
#include <qobject.h>
using namespace NeteaseCloudMusic;

UserProfileViewModel::UserProfileViewModel(QObject* parent) : QObject(parent) {}

UserProfileViewModel* UserProfileViewModel::create(QQmlEngine*, QJSEngine*) {
    return new UserProfileViewModel();
}

void UserProfileViewModel::loadUserProfile() {
    CloudMusicClient::getInstance()->getLoginStatus([this](Result<LoginStatusEntity> result) {
        if (result.isErr()) {
            emit loadUserProfileFailed(result.unwrapErr().message);
            return;
        }
        auto entity = result.unwrap();
        if (!entity.account.has_value() || entity.account.value().anonimousUser) {
            setIsLogin(false);
        } else {
            setIsLogin(true);
        }
        setUserProfileModel(UserProfile(entity));
        emit loadUserProfileSuccess();
    });
}

bool UserProfileViewModel::getIsLogin() const {
    return isLogin;
}

void UserProfileViewModel::setIsLogin(bool newIsLogin) {
    if (isLogin == newIsLogin)
        return;
    isLogin = newIsLogin;
    emit isLoginChanged();
}

UserId UserProfileViewModel::getUserId() const {
    return userProfileModel.userId;
}

QString UserProfileViewModel::getNickname() const {
    return userProfileModel.nickname;
}

QString UserProfileViewModel::getAvatarUrl() const {
    return userProfileModel.avatarUrl;
}

bool UserProfileViewModel::getDefaultAvatar() const {
    return userProfileModel.defaultAvatar;
}

void UserProfileViewModel::setUserProfileModel(const UserProfile& model) {
    userProfileModel = std::move(model);
    emit userIdChanged();
    emit nicknameChanged();
    emit avatarUrlChanged();
    emit defaultAvatarChanged();
}
