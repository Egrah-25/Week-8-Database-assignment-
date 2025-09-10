# 🏥 Clinic Booking System – Database Project

## 📌 Overview
This project implements a **Clinic Booking System** using MySQL.  
The goal is to demonstrate good **database design principles** including normalization, proper constraints, and relational integrity.  

It covers **patients, doctors, specialties, appointments, prescriptions, invoices, and staff accounts**.

---

## 🎯 Objectives
- Apply **database normalization** up to 3NF.  
- Use **PRIMARY KEY, FOREIGN KEY, UNIQUE, and NOT NULL** constraints.  
- Model different relationship types:
  - **One-to-Many:** Patient → Appointments  
  - **One-to-Many:** Doctor → Appointments  
  - **One-to-Many:** Appointment → Prescriptions  
  - **One-to-One:** Appointment → Invoice  
  - **Many-to-Many:** Doctor ↔ Specialties  

---

## 🗄️ Database Schema

### Tables
1. **Patients** – stores patient information.  
2. **Doctors** – stores doctor information and license numbers.  
3. **Specialties** – lookup table for medical specialties.  
4. **DoctorSpecialties** – junction table (many-to-many).  
5. **Rooms** – clinic rooms where appointments take place.  
6. **Appointments** – links patients, doctors, and rooms.  
7. **Prescriptions** – medications prescribed in appointments.  
8. **Invoices** – billing info linked one-to-one with appointments.  
9. **Users** – accounts for clinic staff (admins, receptionists, doctors).  

---

## 🔗 Relationships
- **Patients (1) → (∞) Appointments**  
- **Doctors (1) → (∞) Appointments**  
- **Appointments (1) → (∞) Prescriptions**  
- **Appointments (1) → (1) Invoices**  
- **Doctors (∞) ↔ (∞) Specialties** via `DoctorSpecialties`  
- **Rooms (1) → (∞) Appointments**  

---

## 🛠️ Constraints
- **PRIMARY KEY**: Used for all main tables.  
- **FOREIGN KEY**: Enforces referential integrity (e.g., appointment must reference a valid patient and doctor).  
- **UNIQUE**: Applied to fields like `email`, `license_number`, and `appointment_number`.  
- **NOT NULL**: Ensures essential attributes are always provided.  
- **CHECK**: Prevents invalid values (e.g., appointment duration > 0, invoice amount ≥ 0).  

---

## 📂 Files
- `clinic_db.sql` → contains:
  - `CREATE DATABASE`  
  - `CREATE TABLE` statements  
  - Relationship constraints  
  - Optional sample inserts (commented out)  
  - A view (`vw_upcoming_appointments`) for quick reporting  

---

## 🚀 How to Run
1. Open **MySQL Workbench** (or CLI).  
2. Run the script:  

```sql
   SOURCE path/to/clinic_db.sql;
