-- 1. Thêm cột mới (DDL an toàn, không lock lâu)
ALTER TABLE USERS 
ADD COLUMN Phone_new VARCHAR(15);

-- 2. Backfill dữ liệu từ cột cũ sang cột mới (chạy nhiều lần theo batch)
UPDATE USERS
SET Phone_new = CAST(Phone AS CHAR)
WHERE Phone_new IS NULL
LIMIT 10000;

-- 3. Đồng bộ dữ liệu mới phát sinh (tránh lệch dữ liệu)
DELIMITER $$

CREATE TRIGGER trg_users_phone_insert
BEFORE INSERT ON USERS
FOR EACH ROW
BEGIN
    SET NEW.Phone_new = CAST(NEW.Phone AS CHAR);
END$$

CREATE TRIGGER trg_users_phone_update
BEFORE UPDATE ON USERS
FOR EACH ROW
BEGIN
    SET NEW.Phone_new = CAST(NEW.Phone AS CHAR);
END$$

DELIMITER ;

-- 4. (Sau khi hệ thống đã chuyển sang dùng Phone_new)
-- DDL cuối cùng để thay thế hoàn toàn cột cũ
ALTER TABLE USERS 
DROP COLUMN Phone,
CHANGE Phone_new Phone VARCHAR(15);