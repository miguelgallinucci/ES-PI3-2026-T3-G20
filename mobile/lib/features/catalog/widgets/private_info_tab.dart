import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_section_card.dart';

class PrivateInfoTab extends StatefulWidget {
  final String startupId;

  const PrivateInfoTab({
    super.key,
    required this.startupId,
  });

  @override
  State<PrivateInfoTab> createState() => _PrivateInfoTabState();
}

class _PrivateInfoTabState extends State<PrivateInfoTab> {
  final TextEditingController perguntaController = TextEditingController();

  Future<void> enviarPergunta() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (perguntaController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('startups')
        .doc(widget.startupId)
        .collection('privateQuestions')
        .add({
      'question': perguntaController.text.trim(),
      'answer': '',
      'userId': user.uid,
      'userEmail': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    perguntaController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return AppSectionCard(
      title: 'Perguntas particulares',
      subtitle: 'Somente você verá suas perguntas e respostas',
      child: Column(
        children: [
          TextField(
            controller: perguntaController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Digite sua pergunta privada...',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: enviarPergunta,
              icon: const Icon(Icons.send),
              label: const Text('Enviar pergunta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('startups')
                .doc(widget.startupId)
                .collection('privateQuestions')
                .where('userId', isEqualTo: user?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              final docs = snapshot.data!.docs;

              return Column(
                children: docs.map((doc) {
                  final data = doc.data();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.border,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.question_answer_rounded,
                                color: AppColors.primaryLight,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Sua pergunta',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          data['question'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: data['answer'] == ''
                                ? Colors.orange.withValues(alpha: 0.10)
                                : AppColors.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            data['answer'] == ''
                                ? '⏳ Aguardando resposta da startup'
                                : data['answer'],
                            style: TextStyle(
                              color: data['answer'] == ''
                                  ? Colors.orange
                                  : AppColors.primaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }
}