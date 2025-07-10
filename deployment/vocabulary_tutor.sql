-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 15, 2024 at 02:52 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `vocabulary_tutor`
--

-- --------------------------------------------------------

--
-- Table structure for table `scores`
--

CREATE TABLE `scores` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `scores`
--

INSERT INTO `scores` (`id`, `user_id`, `score`) VALUES
(1, 3, 0),
(2, 3, 0),
(3, 3, 0),
(4, 3, 0),
(5, 3, 0),
(6, 3, 0),
(7, 3, 16),
(8, 3, 16),
(9, 3, 43),
(10, 3, 71),
(11, 3, 96),
(12, 3, 99),
(13, 3, 99),
(14, 3, 28),
(15, 3, 56),
(16, 3, 84),
(17, 3, 112),
(18, 3, 112),
(19, 3, 132),
(20, 3, 160),
(21, 3, 160),
(22, 3, 182),
(23, 3, 26),
(24, 3, 54),
(25, 3, 82),
(26, 3, 82),
(27, 3, 109),
(28, 3, 136),
(29, 3, 192),
(30, 3, 192),
(31, 3, 28),
(32, 3, 56),
(33, 3, 84),
(34, 3, 112),
(35, 3, 140),
(36, 3, 17),
(37, 3, 45),
(38, 3, 95),
(39, 3, 119),
(40, 3, 147),
(41, 3, 22),
(42, 3, 50),
(43, 3, 78),
(44, 3, 78),
(45, 3, 106),
(46, 3, 28),
(47, 3, 55),
(48, 3, 111),
(49, 3, 138),
(50, 3, 166);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`) VALUES
(1, 'elikem', '$2b$12$.n6MQcWJ4LwYUdNS8ZQlTObsAIms0cWbaQnKoNvWZ63J6lA9zbOyO'),
(2, 'tsatsu', '$2b$12$OR3q1n.o/2KU0H/OGSzHC.14AyqsIyuBtMECQa8x4vxAT0IDlLHUC'),
(3, 'testelikem', '$2b$12$WDMqikX2yWHYCGCuEkpRkuIo9ai6M0TNFRH3mxrgKPA8nBChtmjdi');

-- --------------------------------------------------------

--
-- Table structure for table `wrong_clusters`
--

CREATE TABLE `wrong_clusters` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `cluster` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `wrong_clusters`
--

INSERT INTO `wrong_clusters` (`id`, `user_id`, `cluster`) VALUES
(1, 1, 4),
(2, 2, 4),
(3, 2, 4),
(4, 2, 4),
(5, 2, 4),
(6, 3, 4),
(7, 3, 4),
(8, 3, 4),
(9, 3, 4),
(10, 3, 4),
(11, 3, 4),
(12, 3, 4),
(13, 3, 4),
(14, 3, 4);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `scores`
--
ALTER TABLE `scores`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `wrong_clusters`
--
ALTER TABLE `wrong_clusters`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `scores`
--
ALTER TABLE `scores`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `wrong_clusters`
--
ALTER TABLE `wrong_clusters`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `scores`
--
ALTER TABLE `scores`
  ADD CONSTRAINT `scores_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `wrong_clusters`
--
ALTER TABLE `wrong_clusters`
  ADD CONSTRAINT `wrong_clusters_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
