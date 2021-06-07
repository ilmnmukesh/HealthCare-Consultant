// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Medical{
    address hoster;
    struct Doctor {
        address id;
        string doctor_type;
        string name;
        string image;
    }
    
    struct Patient{
        address id;
        string name;
        uint age;
        string problem;
        string gender;
        string symptom;
        address refdoc;
        bool prescribed;
    }
    
    struct Prescription{
        address id;
        string data;
        bool prescribed;
    }
    
    mapping(address=>Patient) patients;
    mapping(address=>Doctor) public doctors;
    
    address[] listOfDoctors;
    address[] listOfPatient;
    
    mapping(address=>address[]) doct_based_patient_lists;
    mapping(address=>Prescription) prescriptions;
    constructor(){
        hoster = msg.sender;
    }
    
    modifier checkHoster(){
        require(hoster==msg.sender, "Hoster only enroll for Doctor's");
        _;
    }
    
    modifier checkNotDoctor(){
        bool flag;
        for(uint x=0;x<listOfDoctors.length;x++){
            if(msg.sender == listOfDoctors[x]){
                flag = true;
                break;
            }
        } 
        if(flag){
          revert("Doctor cannot send as patient");  
        }
        _;
    }
    
    modifier checkDoctorsPatient(address patient_id){
        address[] memory temp= doct_based_patient_lists[msg.sender];
        bool flag;
        for(uint x=0;x< temp.length;x++){
            if(temp[x]==patient_id){
                flag=true;
            }
        }
        if(!flag){
           revert("Patient not belong to this doctor");  
        }
        _;
    }
    
    modifier checkDoctor(){
        bool flag;
        for(uint x=0;x<listOfDoctors.length;x++){
            if(msg.sender == listOfDoctors[x]){
                flag = true;
                break;
            }
        } 
        if(!flag){
          revert("Sender is not a Doctor");  
        }
        _;
    }
    modifier isDoctor(address doctor_id){
        
        if(doctors[doctor_id].id == doctor_id ){
            revert("Doctor Already Enrolled");
        }
        _;
    }
    modifier checkDoctorId(address doctor_id){
        address test;
        require(
          doctors[doctor_id].id != test,
          "Doctor id Not found"
        );
        _;
    }
    
    modifier checkPrescReady(){
        require(
            prescriptions[msg.sender].prescribed,
            "Wait for Doctor Reply"
        );
        _;
    }
    
    modifier againPresc(address patient_id){
        require(
            !patients[patient_id].prescribed,
            "Already prescribed"
        );
        _;
    }
    
    function enrollDoctor(address doctor_, string memory doctor_type_, string memory doctor_name_, string memory image_ )
        public checkHoster isDoctor(doctor_){
        listOfDoctors.push(doctor_);
        doctors[doctor_] = Doctor(doctor_, doctor_type_, doctor_name_, image_);
    }
    
    function showDoctors() public view returns(address[] memory){
        return listOfDoctors;
    }
    
    function findDoctorType(address doctor_id) public view checkDoctorId(doctor_id) returns(string memory) {
        return doctors[doctor_id].doctor_type;
    }
    
    function patient(address doctor_id,string memory name_, uint age_,string memory problem_, string memory gender_, string memory symptom_) 
        public checkDoctorId(doctor_id) checkNotDoctor{
        
        patients[msg.sender]= Patient(msg.sender, name_, age_, problem_,gender_,symptom_, doctor_id, false);
        
        bool flag;
        for(uint x=0;x<listOfPatient.length;x++){
            if(msg.sender==listOfPatient[x]){
                flag=true;
            }
        }
        if(!flag){
            listOfPatient.push(msg.sender);    
        }
        for(uint x=0;x<listOfDoctors.length;x++){
            address[] memory obj= doct_based_patient_lists[listOfDoctors[x]];
            bool test;
            for(uint y=0;y<obj.length;y++){
                if(obj[y] == msg.sender){
                    test=true;
                }
            }
            if(test){
                delete doct_based_patient_lists[listOfDoctors[x]];
                for(uint y=0;y<obj.length;y++){
                    if(obj[y] != msg.sender){
                        doct_based_patient_lists[listOfDoctors[x]].push(obj[y]);
                    }
                }
            }
        }
        doct_based_patient_lists[doctor_id].push(msg.sender);
        
    }
    
    function showPatientList() public view checkDoctor returns(address[] memory){
        return doct_based_patient_lists[msg.sender];
    }
    
    function showPatientProb(address patient_id) public view checkDoctor checkDoctorsPatient(patient_id) returns(Patient memory){
        return patients[patient_id];
    }
    
    function wrotePrescription(address patient_id, string memory data_) public checkDoctor checkDoctorsPatient(patient_id) 
    againPresc(patient_id){
        prescriptions[patient_id] = Prescription(patient_id, data_, true);
        patients[patient_id].prescribed= true;
    }
    
    function showPrescription() public view checkNotDoctor checkPrescReady returns(string memory){
        return prescriptions[msg.sender].data;
    }
}