!> \file
!> $Id$
!> \author Caton Little
!> \brief This module handles non-IO FieldML logic.
!>
!> \section LICENSE
!>
!> Version: MPL 1.1/GPL 2.0/LGPL 2.1
!>
!> The contents of this file are subject to the Mozilla Public License
!> Version 1.1 (the "License"); you may not use this file except in
!> compliance with the License. You may obtain a copy of the License at
!> http://www.mozilla.org/MPL/
!>
!> Software distributed under the License is distributed on an "AS IS"
!> basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
!> License for the specific language governing rights and limitations
!> under the License.
!>
!> The Original Code is OpenCMISS
!>
!> The Initial Developer of the Original Code is University of Auckland,
!> Auckland, New Zealand and University of Oxford, Oxford, United
!> Kingdom. Portions created by the University of Auckland and University
!> of Oxford are Copyright (C) 2007 by the University of Auckland and
!> the University of Oxford. All Rights Reserved.
!>
!> Contributor(s):
!>
!> Alternatively, the contents of this file may be used under the terms of
!> either the GNU General Public License Version 2 or later (the "GPL"), or
!> the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
!> in which case the provisions of the GPL or the LGPL are applicable instead
!> of those above. If you wish to allow use of your version of this file only
!> under the terms of either the GPL or the LGPL, and not to allow others to
!> use your version of this file under the terms of the MPL, indicate your
!> decision by deleting the provisions above and replace them with the notice
!> and other provisions required by the GPL or the LGPL. If you do not delete
!> the provisions above, a recipient may use your version of this file under
!> the terms of any one of the MPL, the GPL or the LGPL.
!>

!> Utility routines for FieldML

MODULE FIELDML_UTIL_ROUTINES

  USE KINDS
  USE FIELDML_API
  USE ISO_VARYING_STRING
  USE STRINGS
  USE OPENCMISS

  IMPLICIT NONE

  PRIVATE

  !Module parameters
  INTEGER(INTG), PARAMETER :: BUFFER_SIZE = 1024

  CHARACTER(C_CHAR), PARAMETER :: NUL=C_NULL_CHAR

  TYPE(VARYING_STRING) :: errorString

  !Interfaces
  TYPE FieldmlInfoType
    TYPE(C_PTR) :: fmlHandle
    INTEGER(C_INT) :: nodesHandle
    INTEGER(C_INT) :: meshHandle
    INTEGER(C_INT) :: elementsHandle
    INTEGER(C_INT) :: xiHandle
    INTEGER(C_INT) :: nodeDofsHandle
    INTEGER(C_INT) :: elementDofsHandle
    INTEGER(C_INT) :: constantDofsHandle
    INTEGER(C_INT), ALLOCATABLE :: componentHandles(:)
    INTEGER(C_INT), ALLOCATABLE :: basisHandles(:)
  END TYPE FieldmlInfoType

  PUBLIC :: FieldmlInfoType

  PUBLIC :: FieldmlUtil_GetConnectivityEnsemble, FieldmlUtil_GetCoordinatesDomain, FieldmlUtil_GetGenericDomain, &
    & FieldmlUtil_GetXiEnsemble, FieldmlUtil_GetXiDomain, FieldmlUtil_GetValueDomain, FieldmlUtil_FinalizeInfo, &
    & FieldmlUtil_GetCollapseSuffix

CONTAINS

  !
  !================================================================================================================================
  !
  
  SUBROUTINE FieldmlUtil_GetCoordinatesDomain( fieldmlHandle, coordsType, dimensions, domainHandle, err )
    !Argument variables
    TYPE(C_PTR), INTENT(IN) :: fieldmlHandle
    INTEGER(C_INT), INTENT(IN) :: coordsType
    INTEGER(C_INT), INTENT(IN) :: dimensions
    INTEGER(C_INT), INTENT(OUT) :: domainHandle
    INTEGER(INTG), INTENT(OUT) :: err

    !Locals
    
    IF( coordsType == CMISSCoordinateRectangularCartesianType ) THEN
      IF( dimensions == 1 ) THEN
        domainHandle = Fieldml_GetNamedObject( fieldmlHandle, "library.coordinates.rc.1d"//NUL )
      ELSE IF( dimensions == 2 ) THEN
        domainHandle = Fieldml_GetNamedObject( fieldmlHandle, "library.coordinates.rc.2d"//NUL )
      ELSE IF( dimensions == 3 ) THEN
        domainHandle = Fieldml_GetNamedObject( fieldmlHandle, "library.coordinates.rc.3d"//NUL )
      ELSE
        domainHandle = FML_INVALID_HANDLE
        err = FML_ERR_UNSUPPORTED
        RETURN
      ENDIF
    ELSE
      domainHandle = FML_INVALID_HANDLE
      err = FML_ERR_UNSUPPORTED
      RETURN
    ENDIF

    err = Fieldml_GetLastError( fieldmlHandle )

  END SUBROUTINE FieldmlUtil_GetCoordinatesDomain
  
  !
  !================================================================================================================================
  !
  
  SUBROUTINE FieldmlUtil_GetGenericDomain( fieldmlHandle, dimensions, domainHandle, err )
    !Argument variables
    TYPE(C_PTR), INTENT(IN) :: fieldmlHandle
    INTEGER(C_INT), INTENT(IN) :: dimensions
    INTEGER(C_INT), INTENT(OUT) :: domainHandle
    INTEGER(INTG), INTENT(OUT) :: err

    !Locals
    
    IF( dimensions == 1 ) THEN
      domainHandle = Fieldml_GetNamedObject( fieldmlHandle, "library.real.1d"//NUL )
    ELSE IF( dimensions == 2 ) THEN
      domainHandle = Fieldml_GetNamedObject( fieldmlHandle, "library.real.2d"//NUL )
    ELSE IF( dimensions == 3 ) THEN
      domainHandle = Fieldml_GetNamedObject( fieldmlHandle, "library.real.3d"//NUL )
    ELSE
      domainHandle = FML_INVALID_HANDLE
      err = FML_ERR_UNSUPPORTED
      RETURN
    ENDIF
    
    err = Fieldml_GetLastError( fieldmlHandle )

  END SUBROUTINE FieldmlUtil_GetGenericDomain
  
  !
  !================================================================================================================================
  !
  
  SUBROUTINE FieldmlUtil_GetXiEnsemble( fieldmlHandle, dimensions, domainHandle, err )
    !Argument variables
    TYPE(C_PTR), INTENT(IN) :: fieldmlHandle
    INTEGER(C_INT), INTENT(IN) :: dimensions
    INTEGER(C_INT), INTENT(OUT) :: domainHandle
    INTEGER(INTG), INTENT(OUT) :: err

    !Locals
    
    IF( dimensions == 1 ) THEN
      domainHandle = Fieldml_GetNamedObject( fieldmlHandle, "library.ensemble.xi.1d"//NUL )
    ELSE IF( dimensions == 2 ) THEN
      domainHandle = Fieldml_GetNamedObject( fieldmlHandle, "library.ensemble.xi.2d"//NUL )
    ELSE IF( dimensions == 3 ) THEN
      domainHandle = Fieldml_GetNamedObject( fieldmlHandle, "library.ensemble.xi.3d"//NUL )
    ELSE
      domainHandle = FML_INVALID_HANDLE
      err = FML_ERR_UNSUPPORTED
      RETURN
    ENDIF
    
    err = Fieldml_GetLastError( fieldmlHandle )

  END SUBROUTINE FieldmlUtil_GetXiEnsemble
  
  !
  !================================================================================================================================
  !
  
  SUBROUTINE FieldmlUtil_GetXiDomain( fieldmlHandle, dimensions, domainHandle, err )
    !Argument variables
    TYPE(C_PTR), INTENT(IN) :: fieldmlHandle
    INTEGER(C_INT), INTENT(IN) :: dimensions
    INTEGER(C_INT), INTENT(OUT) :: domainHandle
    INTEGER(INTG), INTENT(OUT) :: err

    !Locals
    
    IF( dimensions == 1 ) THEN
      domainHandle = Fieldml_GetNamedObject( fieldmlHandle, "library.xi.1d"//NUL )
    ELSE IF( dimensions == 2 ) THEN
      domainHandle = Fieldml_GetNamedObject( fieldmlHandle, "library.xi.2d"//NUL )
    ELSE IF( dimensions == 3 ) THEN
      domainHandle = Fieldml_GetNamedObject( fieldmlHandle, "library.xi.3d"//NUL )
    ELSE
      domainHandle = FML_INVALID_HANDLE
      err = FML_ERR_UNSUPPORTED
      RETURN
    ENDIF
    
    err = Fieldml_GetLastError( fieldmlHandle )

  END SUBROUTINE FieldmlUtil_GetXiDomain
  
  !
  !================================================================================================================================
  !
  
  SUBROUTINE FieldmlUtil_GetCollapseSuffix( collapseInfo, suffix, err )
    !Argument variables
    INTEGER(C_INT), INTENT(IN) :: collapseInfo(:)
    TYPE(VARYING_STRING), INTENT(OUT) :: suffix
    INTEGER(INTG), INTENT(OUT) :: err
    
    !Locals
    INTEGER(INTG) :: i
    
    suffix = ""
    DO i = 1, SIZE( collapseInfo )
      IF( collapseInfo( i ) == CMISSBasisXiCollapsed ) THEN
        suffix = suffix // "_xi"//TRIM(NUMBER_TO_VSTRING(i,"*",err,errorString))//"C"
      ELSEIF( collapseInfo( i ) == CMISSBasisCollapsedAtXi0 ) THEN
        suffix = suffix // "_xi"//TRIM(NUMBER_TO_VSTRING(i,"*",err,errorString))//"0"
      ELSEIF( collapseInfo( i ) == CMISSBasisCollapsedAtXi1 ) THEN
        suffix = suffix // "_xi"//TRIM(NUMBER_TO_VSTRING(i,"*",err,errorString))//"1"
      ENDIF
    ENDDO
  
  END SUBROUTINE
  
  !
  !================================================================================================================================
  !
  
  SUBROUTINE FieldmlUtil_GetTPConnectivityEnsemble( fieldmlHandle, xiInterpolations, collapseInfo, domainHandle, err )
    !Argument variables
    TYPE(C_PTR), INTENT(IN) :: fieldmlHandle
    INTEGER(C_INT), INTENT(IN) :: xiInterpolations(:)
    INTEGER(C_INT), INTENT(IN) :: collapseInfo(:)
    INTEGER(C_INT), INTENT(OUT) :: domainHandle
    INTEGER(INTG), INTENT(OUT) :: err

    !Locals
    INTEGER(C_INT) :: xiCount, firstInterpolation, i
    TYPE(VARYING_STRING) :: suffix
    
    xiCount = SIZE( xiInterpolations )
  
    firstInterpolation = xiInterpolations(1)
    DO i = 2, xiCount
      IF( xiInterpolations(i) /= firstInterpolation ) THEN
        !Do not yet support inhomogeneous TP bases
        err = FML_ERR_INVALID_OBJECT
        RETURN
      ENDIF
    ENDDO

    CALL FieldmlUtil_GetCollapseSuffix( collapseInfo, suffix, err )
    
      
    IF( firstInterpolation == CMISSBasisQuadraticLagrangeInterpolation ) THEN
      IF( xiCount == 1 ) THEN
        domainHandle = Fieldml_GetNamedObject( fieldmlHandle, "library.local_nodes.line.3"//NUL )
      ELSE IF( xiCount == 2 ) THEN
        domainHandle = Fieldml_GetNamedObject( fieldmlHandle, "library.local_nodes.square.3x3"//char(suffix)//NUL )
      ELSE IF( xiCount == 3 ) THEN
        domainHandle = Fieldml_GetNamedObject( fieldmlHandle, "library.local_nodes.cube.3x3x3"//char(suffix)//NUL )
      ELSE
        !Do not yet support dimensions higher than 3.
        err = FML_ERR_INVALID_OBJECT
      ENDIF
    ELSE IF( firstInterpolation == CMISSBasisLinearLagrangeInterpolation ) THEN
      IF( xiCount == 1 ) THEN
        domainHandle = Fieldml_GetNamedObject( fieldmlHandle, "library.local_nodes.line.2"//NUL )
      ELSE IF( xiCount == 2 ) THEN
        domainHandle = Fieldml_GetNamedObject( fieldmlHandle, "library.local_nodes.square.2x2"//char(suffix)//NUL )
      ELSE IF( xiCount == 3 ) THEN
        domainHandle = Fieldml_GetNamedObject( fieldmlHandle, "library.local_nodes.cube.2x2x2"//char(suffix)//NUL )
      ELSE
        !Do not yet support dimensions higher than 3.
        err = FML_ERR_INVALID_OBJECT
      ENDIF
    ELSE
      err = FML_ERR_INVALID_OBJECT
    ENDIF

  END SUBROUTINE FieldmlUtil_GetTPConnectivityEnsemble

  !
  !================================================================================================================================
  !

  SUBROUTINE FieldmlUtil_GetConnectivityEnsemble( fieldmlHandle, basisNumber, domainHandle, err )
    !Argument variables
    TYPE(C_PTR), INTENT(IN) :: fieldmlHandle
    INTEGER(C_INT), INTENT(IN) :: basisNumber
    INTEGER(C_INT), INTENT(OUT) :: domainHandle
    INTEGER(INTG), INTENT(OUT) :: err

    !Locals
    INTEGER(C_INT) :: basisType, xiCount
    INTEGER(C_INT), ALLOCATABLE :: xiInterpolations(:), collapseInfo(:)
    
    domainHandle = FML_INVALID_HANDLE
    
    CALL CMISSBasisTypeGet( basisNumber, basisType, err )
    
    CALL CMISSBasisNumberOfXiGet( basisNumber, xiCount, err )
    
    IF( basisType == CMISSBasisLagrangeHermiteTPType ) THEN
      ALLOCATE( xiInterpolations( xiCount ) )
      ALLOCATE( collapseInfo( xiCount ) )
      CALL CMISSBasisInterpolationXiGet( basisNumber, xiInterpolations, err )
      CALL CMISSBasisCollapsedXiGet( basisNumber, collapseInfo, err )
      
      CALL FieldmlUtil_GetTPConnectivityEnsemble( fieldmlHandle, xiInterpolations, collapseInfo, domainHandle, err )
      
      DEALLOCATE( xiInterpolations )
      DEALLOCATE( collapseInfo )
    ELSE
      err = FML_ERR_INVALID_OBJECT
    ENDIF
    
    IF( domainHandle == FML_INVALID_HANDLE ) THEN
      err = FML_ERR_UNKNOWN_OBJECT
    ENDIF
    
  END SUBROUTINE FieldmlUtil_GetConnectivityEnsemble

  !
  !================================================================================================================================
  !
  
  SUBROUTINE FieldmlUtil_GetValueDomain( fmlHandle, region, field, domainHandle, err )
    !Argument variables
    TYPE(C_PTR), INTENT(IN) :: fmlHandle
    TYPE(CMISSRegionType), INTENT(IN) :: region
    TYPE(CMISSFieldType), INTENT(IN) :: field
    INTEGER(C_INT), INTENT(OUT) :: domainHandle
    INTEGER(INTG), INTENT(OUT) :: err

    !Locals
    INTEGER(INTG) :: fieldType, subType, count
    TYPE(CMISSCoordinateSystemType) coordinateSystem
    
    CALL CMISSFieldTypeGet( field, fieldType, err )
    CALL CMISSFieldNumberOfComponentsGet( field, CMISSFieldUVariableType, count, err )

    SELECT CASE( fieldType )
    CASE( CMISSFieldGeometricType )
      CALL CMISSCoordinateSystemTypeInitialise( coordinateSystem, err )
      CALL CMISSRegionCoordinateSystemGet( region, coordinateSystem, err )
      CALL CMISSCoordinateSystemTypeGet( coordinateSystem, subType, err )
      CALL FieldmlUtil_GetCoordinatesDomain( fmlHandle, subType, count, domainHandle, err )
    
    !CASE( CMISSFieldFibreType )

    !CASE( CMISSFieldGeneralType )

    !CASE( CMISSFieldMaterialType )

    CASE DEFAULT
      CALL FieldmlUtil_GetGenericDomain( fmlHandle, count, domainHandle, err )
    END SELECT
  
  END SUBROUTINE FieldmlUtil_GetValueDomain
    
  !
  !================================================================================================================================
  !
  SUBROUTINE FieldmlUtil_FinalizeInfo( fieldmlInfo )
    !Argument variables
    TYPE(FieldmlInfoType), INTENT(INOUT) :: fieldmlInfo

    !Locals
    INTEGER(INTG) :: err

    err = Fieldml_Destroy( fieldmlInfo%fmlHandle )
    
    fieldmlInfo%fmlHandle = C_NULL_PTR
    fieldmlInfo%nodesHandle = FML_INVALID_HANDLE
    fieldmlInfo%meshHandle = FML_INVALID_HANDLE
    fieldmlInfo%elementsHandle = FML_INVALID_HANDLE
    fieldmlInfo%xiHandle = FML_INVALID_HANDLE
    fieldmlInfo%nodeDofsHandle = FML_INVALID_HANDLE
    fieldmlInfo%elementDofsHandle = FML_INVALID_HANDLE
    fieldmlInfo%constantDofsHandle = FML_INVALID_HANDLE
    
    IF( ALLOCATED( fieldmlInfo%componentHandles ) ) THEN
      DEALLOCATE( fieldmlInfo%componentHandles )
    ENDIF
    IF( ALLOCATED( fieldmlInfo%basisHandles ) ) THEN
      DEALLOCATE( fieldmlInfo%basisHandles )
    ENDIF
    
  END SUBROUTINE FieldmlUtil_FinalizeInfo

  !
  !================================================================================================================================
  !

END MODULE FIELDML_UTIL_ROUTINES
