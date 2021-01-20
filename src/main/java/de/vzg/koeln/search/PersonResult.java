package de.vzg.koeln.search;

import java.util.List;

public class PersonResult {
    private String pse_bibl_id, pse_givenname, pse_surname, academic_degree;

    private List<String> faculty_de,institute_de, other_institution_de;

    public PersonResult() {
    }

    public String getId() {
        return pse_bibl_id;
    }

    public void setId(String pse_bibl_id) {
        this.pse_bibl_id = pse_bibl_id;
    }


    public List<String> getOther_institution_de() {
        return other_institution_de;
    }

    public void setOther_institution_de(List<String> other_institution_de) {
        this.other_institution_de = other_institution_de;
    }

    public String getAcademic_degree() {
        return academic_degree;
    }

    public void setAcademic_degree(String academic_degree) {
        this.academic_degree = academic_degree;
    }

    public String getPse_givenname() {
        return pse_givenname;
    }

    public void setPse_givenname(String pse_givenname) {
        this.pse_givenname = pse_givenname;
    }

    public String getPse_surname() {
        return pse_surname;
    }

    public void setPse_surname(String pse_surname) {
        this.pse_surname = pse_surname;
    }

    public List<String> getFaculty_de() {
        return faculty_de;
    }

    public void setFaculty_de(List<String> faculty_de) {
        this.faculty_de = faculty_de;
    }

    public List<String> getInstitute_de() {
        return institute_de;
    }

    public void setInstitute_de(List<String> institute_de) {
        this.institute_de = institute_de;
    }
}
