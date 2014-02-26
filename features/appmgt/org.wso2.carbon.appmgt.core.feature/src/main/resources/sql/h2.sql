CREATE TABLE IF NOT EXISTS IDN_BASE_TABLE (
            PRODUCT_NAME VARCHAR (20),
            PRIMARY KEY (PRODUCT_NAME)
);

INSERT INTO IDN_BASE_TABLE values ('WSO2 Identity Server');



CREATE TABLE IF NOT EXISTS IDN_OAUTH_CONSUMER_APPS (
            CONSUMER_KEY VARCHAR (512),
            CONSUMER_SECRET VARCHAR (512),
            USERNAME VARCHAR (255),
            TENANT_ID INTEGER DEFAULT 0,
            APP_NAME VARCHAR (255),
            OAUTH_VERSION VARCHAR (128),
            CALLBACK_URL VARCHAR (1024),
            LOGIN_PAGE_URL VARCHAR (1024),
            ERROR_PAGE_URL VARCHAR (1024),
            CONSENT_PAGE_URL VARCHAR (1024),
            GRANT_TYPES VARCHAR (1024),
            PRIMARY KEY (CONSUMER_KEY)
);

CREATE TABLE IF NOT EXISTS IDN_OAUTH1A_REQUEST_TOKEN (
            REQUEST_TOKEN VARCHAR (512),
            REQUEST_TOKEN_SECRET VARCHAR (512),
            CONSUMER_KEY VARCHAR (512),
            CALLBACK_URL VARCHAR (1024),
            SCOPE VARCHAR(2048),
            AUTHORIZED VARCHAR (128),
            OAUTH_VERIFIER VARCHAR (512),
            AUTHZ_USER VARCHAR (512),
            PRIMARY KEY (REQUEST_TOKEN),
            FOREIGN KEY (CONSUMER_KEY) REFERENCES IDN_OAUTH_CONSUMER_APPS(CONSUMER_KEY) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS IDN_OAUTH1A_ACCESS_TOKEN (
            ACCESS_TOKEN VARCHAR (512),
            ACCESS_TOKEN_SECRET VARCHAR (512),
            CONSUMER_KEY VARCHAR (512),
            SCOPE VARCHAR(2048),
            AUTHZ_USER VARCHAR (512),
            PRIMARY KEY (ACCESS_TOKEN),
            FOREIGN KEY (CONSUMER_KEY) REFERENCES IDN_OAUTH_CONSUMER_APPS(CONSUMER_KEY) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS IDN_OAUTH2_AUTHORIZATION_CODE (
            AUTHORIZATION_CODE VARCHAR (512),
            CONSUMER_KEY VARCHAR (512),
            CALLBACK_URL VARCHAR (1024),
            SCOPE VARCHAR(2048),
            AUTHZ_USER VARCHAR (512),
            TIME_CREATED TIMESTAMP,
			VALIDITY_PERIOD BIGINT,
            PRIMARY KEY (AUTHORIZATION_CODE),
            FOREIGN KEY (CONSUMER_KEY) REFERENCES IDN_OAUTH_CONSUMER_APPS(CONSUMER_KEY) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS IDN_OAUTH2_ACCESS_TOKEN (
			ACCESS_TOKEN VARCHAR (255),
			REFRESH_TOKEN VARCHAR (255),
			CONSUMER_KEY VARCHAR (255),
			AUTHZ_USER VARCHAR (255),
			USER_TYPE VARCHAR (25),
			TIME_CREATED TIMESTAMP DEFAULT 0,
			VALIDITY_PERIOD BIGINT,
			TOKEN_SCOPE VARCHAR (25),
			TOKEN_STATE VARCHAR (25) DEFAULT 'ACTIVE',
			TOKEN_STATE_ID VARCHAR (256) DEFAULT 'NONE',
			PRIMARY KEY (ACCESS_TOKEN),
	FOREIGN KEY (CONSUMER_KEY) REFERENCES IDN_OAUTH_CONSUMER_APPS(CONSUMER_KEY) ON DELETE CASCADE,
	CONSTRAINT CON_APP_KEY UNIQUE (CONSUMER_KEY, AUTHZ_USER,USER_TYPE,TOKEN_SCOPE,TOKEN_STATE,TOKEN_STATE_ID)
);

CREATE TABLE IF NOT EXISTS IDN_OPENID_USER_RPS (
			USER_NAME VARCHAR(255) NOT NULL,
			TENANT_ID INTEGER DEFAULT 0,
			RP_URL VARCHAR(255) NOT NULL,
			TRUSTED_ALWAYS VARCHAR(128) DEFAULT 'FALSE',
			LAST_VISIT DATE NOT NULL,
			VISIT_COUNT INTEGER DEFAULT 0,
			DEFAULT_PROFILE_NAME VARCHAR(255) DEFAULT 'DEFAULT',
			PRIMARY KEY (USER_NAME, TENANT_ID, RP_URL)
);

CREATE TABLE IF NOT EXISTS AM_SUBSCRIBER (
    SUBSCRIBER_ID INTEGER AUTO_INCREMENT,
    USER_ID VARCHAR(50) NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    EMAIL_ADDRESS VARCHAR(256) NULL,
    DATE_SUBSCRIBED TIMESTAMP NOT NULL,
    PRIMARY KEY (SUBSCRIBER_ID),
    UNIQUE (TENANT_ID,USER_ID)
);

CREATE TABLE IF NOT EXISTS AM_APPLICATION (
    APPLICATION_ID INTEGER AUTO_INCREMENT,
    NAME VARCHAR(100),
    SUBSCRIBER_ID INTEGER,
    APPLICATION_TIER VARCHAR(50) DEFAULT 'Unlimited',
    CALLBACK_URL VARCHAR(512),
    DESCRIPTION VARCHAR(512),
	APPLICATION_STATUS VARCHAR(50) DEFAULT 'APPROVED',
    FOREIGN KEY(SUBSCRIBER_ID) REFERENCES AM_SUBSCRIBER(SUBSCRIBER_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY(APPLICATION_ID),
    UNIQUE (NAME,SUBSCRIBER_ID)
);

CREATE TABLE IF NOT EXISTS APPMGR_APP (
    API_ID INTEGER AUTO_INCREMENT,
    API_PROVIDER VARCHAR(256),
    API_NAME VARCHAR(256),
    API_VERSION VARCHAR(30),
    CONTEXT VARCHAR(256),
    PRIMARY KEY(API_ID),
    UNIQUE (API_PROVIDER,API_NAME,API_VERSION)
);

CREATE TABLE IF NOT EXISTS APPMGR_APP_URL_MAPPING (
    URL_MAPPING_ID INTEGER AUTO_INCREMENT,
    API_ID INTEGER NOT NULL,
    HTTP_METHOD VARCHAR(20) NULL,
    AUTH_SCHEME VARCHAR(50) NULL,
    URL_PATTERN VARCHAR(512) NULL,
    THROTTLING_TIER varchar(512) DEFAULT NULL,
    PRIMARY KEY(URL_MAPPING_ID)
);


CREATE TABLE IF NOT EXISTS AM_SUBSCRIPTION (
    SUBSCRIPTION_ID INTEGER AUTO_INCREMENT,
    TIER_ID VARCHAR(50),
    API_ID INTEGER,
    LAST_ACCESSED TIMESTAMP NULL,
    APPLICATION_ID INTEGER,
    SUB_STATUS VARCHAR(50),
    FOREIGN KEY(APPLICATION_ID) REFERENCES AM_APPLICATION(APPLICATION_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY(API_ID) REFERENCES APPMGR_APP(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (SUBSCRIPTION_ID)
);

CREATE TABLE IF NOT EXISTS AM_SUBSCRIPTION_KEY_MAPPING (
    SUBSCRIPTION_ID INTEGER,
    ACCESS_TOKEN VARCHAR(512),
    KEY_TYPE VARCHAR(512) NOT NULL,
    FOREIGN KEY(SUBSCRIPTION_ID) REFERENCES AM_SUBSCRIPTION(SUBSCRIPTION_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY(SUBSCRIPTION_ID,ACCESS_TOKEN)
);

CREATE TABLE IF NOT EXISTS AM_APPLICATION_KEY_MAPPING (
    APPLICATION_ID INTEGER,
    CONSUMER_KEY VARCHAR(512),
    KEY_TYPE VARCHAR(512) NOT NULL,
    FOREIGN KEY(APPLICATION_ID) REFERENCES AM_APPLICATION(APPLICATION_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY(APPLICATION_ID,CONSUMER_KEY)
);

CREATE TABLE IF NOT EXISTS APPMGR_APP_LC_EVENT (
    EVENT_ID INTEGER AUTO_INCREMENT,
    API_ID INTEGER NOT NULL,
    PREVIOUS_STATE VARCHAR(50),
    NEW_STATE VARCHAR(50) NOT NULL,
    USER_ID VARCHAR(50) NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    EVENT_DATE TIMESTAMP NOT NULL,
    FOREIGN KEY(API_ID) REFERENCES APPMGR_APP(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (EVENT_ID)
);

CREATE TABLE AM_APP_KEY_DOMAIN_MAPPING (
    CONSUMER_KEY VARCHAR(255),
    AUTHZ_DOMAIN VARCHAR(255) DEFAULT 'ALL',
    PRIMARY KEY (CONSUMER_KEY,AUTHZ_DOMAIN),
    FOREIGN KEY (CONSUMER_KEY) REFERENCES IDN_OAUTH_CONSUMER_APPS(CONSUMER_KEY)
);

CREATE TABLE IF NOT EXISTS APPMGR_APP_COMMENTS (
    COMMENT_ID INTEGER AUTO_INCREMENT,
    COMMENT_TEXT VARCHAR(512),
    COMMENTED_USER VARCHAR(255),
    DATE_COMMENTED TIMESTAMP NOT NULL,
    API_ID INTEGER NOT NULL,
    FOREIGN KEY(API_ID) REFERENCES APPMGR_APP(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (COMMENT_ID)
);

CREATE TABLE IF NOT EXISTS APPMGR_APP_RATINGS(
    RATING_ID INTEGER AUTO_INCREMENT,
    API_ID INTEGER,
    RATING INTEGER,
    SUBSCRIBER_ID INTEGER,
    FOREIGN KEY(API_ID) REFERENCES APPMGR_APP(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY(SUBSCRIBER_ID) REFERENCES AM_SUBSCRIBER(SUBSCRIBER_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (RATING_ID)
);

CREATE TABLE IF NOT EXISTS AM_TIER_PERMISSIONS (
    TIER_PERMISSIONS_ID INTEGER AUTO_INCREMENT,
    TIER VARCHAR(50) NOT NULL,
    PERMISSIONS_TYPE VARCHAR(50) NOT NULL,
    ROLES VARCHAR(512) NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    PRIMARY KEY(TIER_PERMISSIONS_ID)
);

CREATE TABLE IF NOT EXISTS IDN_THRIFT_SESSION (
       SESSION_ID VARCHAR(255) NOT NULL,
       USER_NAME VARCHAR(255) NOT NULL,
       CREATED_TIME VARCHAR(255) NOT NULL,
       LAST_MODIFIED_TIME VARCHAR(255) NOT NULL,
       PRIMARY KEY (SESSION_ID)
);
CREATE TABLE IF NOT EXISTS AM_EXTERNAL_STORES(
    APISTORE_ID INTEGER AUTO_INCREMENT,
    API_ID INTEGER,
    STORE_ID VARCHAR(255) NOT NULL,
    STORE_DISPLAY_NAME VARCHAR(255) NOT NULL,
    STORE_ENDPOINT VARCHAR(255) NOT NULL,
    STORE_TYPE VARCHAR(255) NOT NULL,
    FOREIGN KEY(API_ID) REFERENCES APPMGR_APP(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (APISTORE_ID)
);

CREATE TABLE IF NOT EXISTS AM_WORKFLOWS(
    WF_ID INTEGER AUTO_INCREMENT,
    WF_REFERENCE VARCHAR(255) NOT NULL,
    WF_TYPE VARCHAR(255) NOT NULL,
    WF_STATUS VARCHAR(255) NOT NULL,
    WF_CREATED_TIME TIMESTAMP,
    WF_UPDATED_TIME TIMESTAMP,
    WF_STATUS_DESC VARCHAR(1000),
    TENANT_ID INTEGER,
    TENANT_DOMAIN VARCHAR(255),
    WF_EXTERNAL_REFERENCE VARCHAR(255) NOT NULL,
    PRIMARY KEY (WF_ID),
    UNIQUE (WF_EXTERNAL_REFERENCE)
);

CREATE INDEX IDX_SUB_APP_ID ON AM_SUBSCRIPTION (APPLICATION_ID, SUBSCRIPTION_ID);
CREATE INDEX IDX_AT_CK_AU ON IDN_OAUTH2_ACCESS_TOKEN(CONSUMER_KEY, AUTHZ_USER, TOKEN_STATE, USER_TYPE);
