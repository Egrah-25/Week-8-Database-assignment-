-- ============================================================================
-- Clinic Booking System - Database Schema
-- Deliverable: single .sql file containing CREATE DATABASE and CREATE TABLEs
-- Intended for MySQL 8.x (uses InnoDB and CHECK constraints)
-- ============================================================================

-- Drop DB if it exists (safe to rerun)
DROP DATABASE IF EXISTS clinic_db;
CREATE DATABASE clinic_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE clinic_db;

-- ============================
-- Table: Patients
-- One patient per row. email unique.
-- ============================
CREATE TABLE Patients (
  patient_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(80) NOT NULL,
  last_name VARCHAR(80) NOT NULL,
  date_of_birth DATE,
  gender ENUM('Male','Female','Other') DEFAULT 'Other',
  email VARCHAR(150) UNIQUE,
  phone VARCHAR(30),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================
-- Table: Doctors
-- One doctor per row. license_number unique.
-- ============================
CREATE TABLE Doctors (
  doctor_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(80) NOT NULL,
  last_name VARCHAR(80) NOT NULL,
  license_number VARCHAR(50) NOT NULL UNIQUE,
  phone VARCHAR(30),
  email VARCHAR(150),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================
-- Table: Specialties
-- Lookup table for doctor specialties (e.g., Cardiology)
-- ============================
CREATE TABLE Specialties (
  specialty_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description VARCHAR(255)
) ENGINE=InnoDB;

-- ============================
-- Table: DoctorSpecialties (many-to-many)
-- A doctor can have multiple specialties and a specialty can belong to many doctors
-- ============================
CREATE TABLE DoctorSpecialties (
  doctor_id INT NOT NULL,
  specialty_id INT NOT NULL,
  PRIMARY KEY (doctor_id, specialty_id),
  CONSTRAINT fk_ds_doctor FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ds_specialty FOREIGN KEY (specialty_id) REFERENCES Specialties(specialty_id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================
-- Table: Rooms
-- Clinic rooms where appointments happen
-- ============================
CREATE TABLE Rooms (
  room_id INT AUTO_INCREMENT PRIMARY KEY,
  room_number VARCHAR(20) NOT NULL UNIQUE,
  floor VARCHAR(20),
  notes VARCHAR(255)
) ENGINE=InnoDB;

-- ============================
-- Table: Appointments
-- One appointment is for one patient with one doctor (many appointments per patient, per doctor)
-- This models a One-to-Many (Patients -> Appointments) and (Doctors -> Appointments).
-- ============================
CREATE TABLE Appointments (
  appointment_id INT AUTO_INCREMENT PRIMARY KEY,
  appointment_number VARCHAR(50) NOT NULL UNIQUE,
  patient_id INT NOT NULL,
  doctor_id INT NOT NULL,
  room_id INT NULL,
  appointment_date DATETIME NOT NULL,
  duration_minutes INT NOT NULL DEFAULT 30,
  status ENUM('Scheduled','Completed','Cancelled','No-Show') DEFAULT 'Scheduled',
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_appt_patient FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_appt_doctor FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_appt_room FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  -- Avoid negative duration
  CHECK (duration_minutes > 0)
) ENGINE=InnoDB;

-- Indexes to speed common lookups
CREATE INDEX idx_appointments_patient ON Appointments(patient_id);
CREATE INDEX idx_appointments_doctor ON Appointments(doctor_id);
CREATE INDEX idx_appointments_date ON Appointments(appointment_date);

-- ============================
-- Table: Prescriptions
-- One-to-Many: Appointment -> Prescriptions (an appointment can produce multiple prescriptions)
-- ============================
CREATE TABLE Prescriptions (
  prescription_id INT AUTO_INCREMENT PRIMARY KEY,
  appointment_id INT NOT NULL,
  medication_name VARCHAR(150) NOT NULL,
  dosage VARCHAR(80),
  frequency VARCHAR(80),
  notes VARCHAR(255),
  issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_presc_appointment FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================
-- Table: Invoices
-- Optional billing information for appointments (1-to-1 or 1-to-many depending on model).
-- We'll model 1 invoice per appointment for simplicity (One-to-One enforced by UNIQUE)
-- ============================
CREATE TABLE Invoices (
  invoice_id INT AUTO_INCREMENT PRIMARY KEY,
  appointment_id INT NOT NULL UNIQUE,
  amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
  paid BOOLEAN DEFAULT FALSE,
  issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_invoice_appt FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================
-- Table: Users (accounts for clinic staff)
-- Demonstrates access control user accounts separate from Doctors table
-- ============================
CREATE TABLE Users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(80) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('Admin','Reception','Nurse','Doctor') NOT NULL DEFAULT 'Reception',
  doctor_id INT NULL, -- link to Doctors when role = Doctor (optional)
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_users_doctor FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- Indexes for performance
CREATE INDEX idx_users_role ON Users(role);

-- ============================
-- Optional: Additional constraints or helper views
-- (Example: a view showing upcoming appointments)
-- ============================
CREATE OR REPLACE VIEW vw_upcoming_appointments AS
SELECT a.appointment_id,
       a.appointment_number,
       a.appointment_date,
       a.duration_minutes,
       a.status,
       p.patient_id,
       p.first_name AS patient_first,
       p.last_name  AS patient_last,
       d.doctor_id,
       d.first_name AS doctor_first,
       d.last_name  AS doctor_last,
       r.room_number
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d  ON a.doctor_id  = d.doctor_id
LEFT JOIN Rooms r ON a.room_id = r.room_id
WHERE a.appointment_date >= NOW()
ORDER BY a.appointment_date ASC;

-- ============================================================================
-- OPTIONAL: Sample data (uncomment to insert example rows for quick testing)
-- ============================================================================
/*
INSERT INTO Patients (first_name, last_name, date_of_birth, gender, email, phone)
VALUES
('Amina', 'Njeri', '1996-04-12', 'Female', 'amina.njeri@example.com', '+254700111222'),
('Brian', 'Otieno', '1988-09-02', 'Male', 'brian.otieno@example.com', '+254700333444');

INSERT INTO Doctors (first_name, last_name, license_number, phone, email)
VALUES
('Dr. John', 'Mwangi', 'LIC-2020-001', '+254701111222', 'j.mwangi@clinic.com'),
('Dr. Grace', 'Kiptoo', 'LIC-2019-045', '+254702222333', 'g.kiptoo@clinic.com');

INSERT INTO Specialties (name, description)
VALUES ('General Practice', 'General family medicine'),
       ('Pediatrics', 'Child health');

INSERT INTO DoctorSpecialties (doctor_id, specialty_id)
VALUES (1, 1), (2, 1), (2, 2);

INSERT INTO Rooms (room_number, floor)
VALUES ('101', '1'), ('201', '2');

INSERT INTO Appointments (appointment_number, patient_id, doctor_id, room_id, appointment_date, duration_minutes, status)
VALUES
('APT-0001', 1, 1, 1, '2025-08-12 09:30:00', 30, 'Scheduled'),
('APT-0002', 2, 2, 2, '2025-08-12 10:30:00', 45, 'Scheduled');

INSERT INTO Prescriptions (appointment_id, medication_name, dosage, frequency)
VALUES (1, 'Amoxicillin', '500mg', '3 times a day');

INSERT INTO Invoices (appointment_id, amount, paid)
VALUES (1, 5000.00, FALSE);

INSERT INTO Users (username, password_hash, role, doctor_id)
VALUES ('admin', 'dummyhash', 'Admin', NULL);
*/

-- ============================================================================
-- End of schema
-- ============================================================================
