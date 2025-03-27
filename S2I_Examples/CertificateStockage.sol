// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CertificateStorage {
    struct Certificate {
        string studentName;
        string courseName;
        uint256 dateIssued;
        address issuedBy;
    }

    Certificate[] public certificates;

    event CertificateIssued(string studentName, string courseName, uint256 dateIssued, address issuedBy);

    // Émettre un nouveau certificat
    function issueCertificate(string memory _studentName, string memory _courseName) public {
        certificates.push(
            Certificate({
                studentName: _studentName,
                courseName: _courseName,
                dateIssued: block.timestamp,
                issuedBy: msg.sender
            })
        );

        emit CertificateIssued(_studentName, _courseName, block.timestamp, msg.sender);
    }

    // Récupérer les détails d'un certificat
    function getCertificate(uint256 index) public view returns (
        string memory, string memory, uint256, address
    ) {
        require(index < certificates.length, "Invalid index");
        Certificate memory cert = certificates[index];
        return (cert.studentName, cert.courseName, cert.dateIssued, cert.issuedBy);
    }

    function totalCertificates() public view returns (uint256) {
        return certificates.length;
    }
}

contract CertificateFactory {
    CertificateStorage[] public certificateStorages;

    event StorageCreated(address storageAddress);

    // Crée une nouvelle instance de stockage de certificats (par exemple pour une nouvelle école ou université)
    function createCertificateStorage() public {
        CertificateStorage newStorage = new CertificateStorage();
        certificateStorages.push(newStorage);
        emit StorageCreated(address(newStorage));
    }

    // Accès à une instance précise
    function getStorage(uint256 index) public view returns (CertificateStorage) {
        require(index < certificateStorages.length, "Invalid index");
        return certificateStorages[index];
    }

    function totalStorages() public view returns (uint256) {
        return certificateStorages.length;
    }
}
