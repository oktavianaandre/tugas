-- phpMyAdmin SQL Dump
-- version 5.0.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 25, 2024 at 11:17 AM
-- Server version: 10.4.14-MariaDB
-- PHP Version: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `inventoryweb`
--

-- --------------------------------------------------------

--
-- Table structure for table `barang`
--

CREATE TABLE `barang` (
  `id_barang` varchar(20) NOT NULL,
  `nama_barang` varchar(60) DEFAULT NULL,
  `stok` varchar(4) DEFAULT NULL,
  `id_satuan` int(20) DEFAULT NULL,
  `jenis` varchar(20) DEFAULT NULL,
  `merk` varchar(20) NOT NULL,
  `foto` varchar(225) DEFAULT NULL,
  `tgl_produksi` date DEFAULT NULL,
  `tgl_expired` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `barang`
--

INSERT INTO `barang` (`id_barang`, `nama_barang`, `stok`, `id_satuan`, `jenis`, `merk`, `foto`, `tgl_produksi`, `tgl_expired`) VALUES
('BRG-0003', 'OLI', '300', 1, 'Pelumas', 'Yamaha', 'ESP.png', '2023-01-01', '2025-01-01'),
('BRG-0004', 'Ban', '1000', 2, 'Sparepart', 'Yamaha', 'aqua.jpg', '2022-06-01', '2024-06-01'),
('BRG-0005', 'Busi', '120', 1, 'Sparepart', 'Kawasaki', 'box.png', '2024-06-12', '2025-10-22'),
('BRG-0006', 'Karburator', '350', 2, 'Sparepart', 'Yamaha', 'box.png', '2024-06-01', '2024-06-30'),
('BRG-0007', 'Rantai', '444', 2, 'Sparepart', 'Yamaha', 'box.png', '2024-01-06', '2024-06-19'),
('BRG-0008', 'Gembok Motor', '200', 5, 'Aksesori', 'Yamaha', 'box.png', '2024-06-01', '2024-07-01');

-- --------------------------------------------------------

--
-- Table structure for table `barang_keluar`
--

CREATE TABLE `barang_keluar` (
  `id_barang_keluar` varchar(30) NOT NULL,
  `id_barang` varchar(30) DEFAULT NULL,
  `id_user` varchar(30) DEFAULT NULL,
  `jenis` varchar(20) NOT NULL,
  `merk` varchar(20) NOT NULL,
  `jumlah_keluar` varchar(5) DEFAULT NULL,
  `tgl_keluar` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `barang_keluar`
--

INSERT INTO `barang_keluar` (`id_barang_keluar`, `id_barang`, `id_user`, `jenis`, `merk`, `jumlah_keluar`, `tgl_keluar`) VALUES
('BRG-K-0003', 'BRG-0007', 'USR-005', 'Oli', 'Suzuki', '1', '2024-06-24'),
('BRG-K-0004', 'BRG-0006', 'USR-005', 'Sparepart', 'Honda', '22', '2024-06-25'),
('BRG-K-0005', 'BRG-0003', 'USR-005', 'Pelumas', 'Yamaha', '9', '2024-06-25'),
('BRG-K-0006', 'BRG-0004', 'USR-005', 'Ban', 'Yamaha', '1', '2024-06-25');

-- --------------------------------------------------------

--
-- Table structure for table `barang_masuk`
--

CREATE TABLE `barang_masuk` (
  `id_barang_masuk` varchar(40) NOT NULL,
  `id_supplier` varchar(30) DEFAULT NULL,
  `id_barang` varchar(30) DEFAULT NULL,
  `id_user` varchar(30) DEFAULT NULL,
  `jenis` varchar(20) NOT NULL,
  `merk` varchar(20) NOT NULL,
  `jumlah_masuk` int(10) DEFAULT NULL,
  `tgl_masuk` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `barang_masuk`
--

INSERT INTO `barang_masuk` (`id_barang_masuk`, `id_supplier`, `id_barang`, `id_user`, `jenis`, `merk`, `jumlah_masuk`, `tgl_masuk`) VALUES
('BRG-M-0001', 'SPLY-0003', 'BRG-0002', 'USR-001', '1', '', 30, '2020-09-15'),
('BRG-M-0003', 'SPLY-0004', 'BRG-0007', 'USR-005', '5', '', 221, '2024-06-24'),
('BRG-M-0004', 'SPLY-0004', 'BRG-0006', 'USR-005', '5', '', 122, '2024-06-24'),
('BRG-M-0007', 'SPLY-0001', 'BRG-0007', 'USR-005', 'Oli', 'Suzuki', 55, '2024-06-24');

-- --------------------------------------------------------

--
-- Table structure for table `jenis`
--

CREATE TABLE `jenis` (
  `id_jenis` int(20) NOT NULL,
  `nama_jenis` varchar(20) DEFAULT NULL,
  `merk` varchar(50) DEFAULT NULL,
  `ket` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `jenis`
--

INSERT INTO `jenis` (`id_jenis`, `nama_jenis`, `merk`, `ket`) VALUES
(1, 'Sparepart', 'Kawasaki', ''),
(3, 'Pelumas', 'Yamaha', ''),
(5, 'Krengkes', 'Honda', '');

-- --------------------------------------------------------

--
-- Table structure for table `satuan`
--

CREATE TABLE `satuan` (
  `id_satuan` int(20) NOT NULL,
  `nama_satuan` varchar(60) DEFAULT NULL,
  `ket` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `satuan`
--

INSERT INTO `satuan` (`id_satuan`, `nama_satuan`, `ket`) VALUES
(1, 'Litter', ''),
(2, 'Unit', ''),
(4, 'Meter', ''),
(5, 'Set', '');

-- --------------------------------------------------------

--
-- Table structure for table `supplier`
--

CREATE TABLE `supplier` (
  `id_supplier` varchar(10) NOT NULL,
  `nama_supplier` varchar(60) DEFAULT NULL,
  `notelp` varchar(15) DEFAULT NULL,
  `alamat` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `supplier`
--

INSERT INTO `supplier` (`id_supplier`, `nama_supplier`, `notelp`, `alamat`) VALUES
('SPLY-0001', 'Astra Honda Motor', '087817379229', 'Jl mm2100'),
('SPLY-0002', 'Heri Perdiansyah', '0898', 'Sumedang'),
('SPLY-0003', 'Widi Priansyah', '08998279536', 'Sumedang'),
('SPLY-0004', 'Okta', '1234', 'Denso');

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `id_user` varchar(50) NOT NULL,
  `nama` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `notelp` varchar(15) NOT NULL,
  `level` enum('petugas','admin','manajer') NOT NULL,
  `password` varchar(255) NOT NULL,
  `foto` varchar(50) NOT NULL,
  `status` enum('Aktif','Tidak Aktif') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`id_user`, `nama`, `username`, `email`, `notelp`, `level`, `password`, `foto`, `status`) VALUES
('USR-004', 'willy', 'willy', 'oktavianaandree@gmail.com', '088739898299', 'admin', '35284e329c3a5f1c2af846329ae7b8e9', 'desain_lagi.jpeg', 'Aktif'),
('USR-005', 'farel', 'farel', 'oktacitamvan@gmail.com', '08998279536', 'petugas', 'cb14c8bb3ef9b92646dd460d530b6056', 'lp3ii.png', 'Aktif'),
('USR-007', 'Oktaviana Andre', 'okta', 'oktavianaandree@gmail.com', '08998279536', 'admin', '658276e9dfa2ee601962801a0277b1a0', 'pelk.png', 'Aktif'),
('USR-008', 'alfa', 'alfa', 'alfa@gmail.com', '089754676478', 'petugas', '730703f98d615e28a17c00e5b2784ab1', 'LOGO_PKKMB.png', 'Aktif'),
('USR-009', 'wwwww', 'wwww', 'oktavianaandree@gmail.com', '777745345554325', 'admin', '658276e9dfa2ee601962801a0277b1a0', 'Picture1.png', 'Aktif');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `barang`
--
ALTER TABLE `barang`
  ADD PRIMARY KEY (`id_barang`);

--
-- Indexes for table `barang_keluar`
--
ALTER TABLE `barang_keluar`
  ADD PRIMARY KEY (`id_barang_keluar`);

--
-- Indexes for table `barang_masuk`
--
ALTER TABLE `barang_masuk`
  ADD PRIMARY KEY (`id_barang_masuk`);

--
-- Indexes for table `jenis`
--
ALTER TABLE `jenis`
  ADD PRIMARY KEY (`id_jenis`);

--
-- Indexes for table `satuan`
--
ALTER TABLE `satuan`
  ADD PRIMARY KEY (`id_satuan`);

--
-- Indexes for table `supplier`
--
ALTER TABLE `supplier`
  ADD PRIMARY KEY (`id_supplier`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id_user`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `jenis`
--
ALTER TABLE `jenis`
  MODIFY `id_jenis` int(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `satuan`
--
ALTER TABLE `satuan`
  MODIFY `id_satuan` int(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
