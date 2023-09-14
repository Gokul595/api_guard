## Changelog

### 0.6.0 - 2022-03-21

* Features
  * [Pull #55](https://github.com/Gokul595/api_guard/pull/55) - Adds expiry to refresh tokens.

### 0.5.1 - 2020-11-08

* Bug fixes
    * [Issue #30](https://github.com/Gokul595/api_guard/issues/30) - Prevent sharing authenticated resource across the
    requests.

### 0.5.0 - 2020-09-13

* Dependency upgrade
    * [Pull #29](https://github.com/Gokul595/api_guard/pull/29) - Upgraded all dependent gems and removed support for
    ruby version less than 2.5.

### 0.4.0 - 2020-04-26

* Features
    * [Pull #24](https://github.com/Gokul595/api_guard/pull/24) - Add custom data in JWT token & customize resource 
    finding logic.

### 0.3.0 - 2019-09-14

* Features
    * [Pull #15](https://github.com/Gokul595/api_guard/pull/15) - Added option to customize / translate response 
    messages using I18n.

### 0.2.2 - 2019-08-08

* Bug fixes
    * [Issue #11](https://github.com/Gokul595/api_guard/issues/11) - Added code to detect `secret_key_base` from various 
    configs as the location is not same in all Rails versions. 

### 0.2.1 - 2019-05-22

* Bug fixes
    * [Issue #11](https://github.com/Gokul595/api_guard/issues/11) - Skip verifying authenticity token as everything 
    is API here.

### 0.2.0 - 2019-04-27

* Features
    * Added configurable option to revoke JWT access token on refreshing as requested in this 
    [issue comment](https://github.com/Gokul595/api_guard/issues/8#issuecomment-477436164).

### 0.1.3 - 2019-03-26

* Bug fixes
    * [Issue #5](https://github.com/Gokul595/api_guard/issues/5) - Fixed issue in accessing the JWT access token.

### 0.1.2 - 2019-03-23

* Bug fixes
    * [Issue #3](https://github.com/Gokul595/api_guard/issues/3) - Fixed issue in accessing the `secret_key_base` in 
    Rails `>= 5.2` by using `credentials` 

### 0.1.1 Initial version
