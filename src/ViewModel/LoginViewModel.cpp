#include "LoginViewModel.h"
#include "Service/NeteaseCloudMusic/Response/LoginQRCodePollingEntity.h"
#include <Service/NeteaseCloudMusic/CloudMusicClient.h>
#include <qnetworkcookiejar.h>
using namespace NeteaseCloudMusic;

LoginViewModel::LoginViewModel(QObject* parent) : QObject(parent) {
    connect(&this->m_timer, &QTimer::timeout, this, &LoginViewModel::loginQRCodePolling);
    this->m_timer.setInterval(10000);
    this->m_timer.setSingleShot(false);
}

void LoginViewModel::newLoginQRCode() {
    CloudMusicClient::getInstance()->newLoginQRCode([this](Result<LoginQRCodeEntity> result) {
        if (result.isErr()) {
            emit loginQRCodeNewFailed(result.unwrapErr().message);
            this->m_status = LoginQRCodePollingStatus::Unknown;
            emit onStatusChanged();
            return;
        }
        auto entity = result.unwrap();
        this->m_key = entity.key;
        this->m_qrCodeData = entity.qrCodeData;
        emit onQRCodeDataChanged();
        this->m_timer.start();
    });
}

void LoginViewModel::logout() {
    CloudMusicClient::getInstance()->logout([](Result<QJsonObject> result) {
        if (result.isErr()) {
            return;
        }
        auto entity = result.unwrap();
        qDebug() << entity;
    });
}

void LoginViewModel::loginQRCodePolling() {
    CloudMusicClient::getInstance()->loginQRCodePolling(this->m_key, [this](Result<LoginQRCodePollingEntity> result) {
        if (result.isErr()) {
            emit loginQRCodePollingFailed(result.unwrapErr().message);
            return;
        }
        auto entity = result.unwrap();
        if (entity.status == LoginQRCodePollingStatus::Success || entity.status == LoginQRCodePollingStatus::Timeout) {
            this->m_timer.stop();
        }
        if (this->m_status != entity.status) {
            this->m_status = entity.status;
            emit onStatusChanged();
        }
        if (entity.status == LoginQRCodePollingStatus::Success) {
        }
    });
}

QString LoginViewModel::getQRCodeData() const {
    return this->m_qrCodeData;
}

NeteaseCloudMusic::LoginQRCodePollingStatus LoginViewModel::getStatus() const {
    return this->m_status;
}
