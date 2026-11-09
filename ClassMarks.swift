/*
 * ClassMarks.swift
 * Author: MFROB
 * Date: 2026-11-09

 * Reads students.txt and assignments.txt into arrays, randomly generates
 * integer marks for each student (mean 75, standard deviation 10) using
 * GenerateMarks, and saves the results to marks.csv.
 */

import Foundation

// Reads a text file (one item per line) and returns the lines as an array
func readFile(_ filename: String) -> [String] {
    guard let contents = try? String(contentsOfFile: filename, encoding: .utf8) else {
        print("Could not read \(filename)")
        return []
    }
    return contents
        .split(whereSeparator: \.isNewline)
        .map { String($0).trimmingCharacters(in: .whitespaces) }
        .filter { !$0.isEmpty }
}

// Swift has no built-in Gaussian, so use the Box-Muller transform
// (mean 0, standard deviation 1 - same as Java's nextGaussian())
func nextGaussian() -> Double {
    let u1 = Double.random(in: Double.leastNonzeroMagnitude..<1)
    let u2 = Double.random(in: 0..<1)
    return sqrt(-2 * log(u1)) * cos(2 * Double.pi * u2)
}

// Builds the 2D array of names and randomly generated marks
func GenerateMarks(_ studentArray: [String], _ assignmentsArray: [String]) -> [[String]] {
    var marks: [[String]] = []

    // header row
    marks.append(["Student"] + assignmentsArray)

    // one row per student
    for student in studentArray {
        var row = [student]
        for _ in assignmentsArray {
            let mark = Int((nextGaussian() * 10 + 75).rounded())
            row.append(String(mark))
        }
        marks.append(row)
    }
    return marks
}

// Writes the 2D array to a CSV file
func writeCSV(_ filename: String, _ data: [[String]]) {
    let csv = data.map { $0.joined(separator: ",") }.joined(separator: "\n") + "\n"
    do {
        try csv.write(toFile: filename, atomically: true, encoding: .utf8)
    } catch {
        print("Could not write \(filename): \(error)")
    }
}

// main
let studentArray = readFile("students.txt")
let assignmentsArray = readFile("assignments.txt")

let marks = GenerateMarks(studentArray, assignmentsArray)
writeCSV("marks.csv", marks)

print("marks.csv created with \(marks.count - 1) students and \(assignmentsArray.count) assignments.")