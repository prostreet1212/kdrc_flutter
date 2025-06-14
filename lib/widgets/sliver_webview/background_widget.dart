

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/error_text_cubit.dart';

class BackgroundWidget extends StatelessWidget {
  const BackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      key: const PageStorageKey('aaa'),
      child: Stack(
        children: [
          Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.7),
            width: double.infinity,
            //fit: BoxFit.cover,
          ),
          BlocBuilder<ErrorTextCubit, bool>(
            builder: (context, internetStatetate) {
              if (internetStatetate) {
                return const SizedBox();
              } else {
                return Align(
                  alignment: const Alignment(0, 0.9),
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width / 5,
                        //9.5,
                        right: MediaQuery.of(context).size.width / 5,
                        //9.5,
                        top: MediaQuery.of(context)
                            .size
                            .height /
                            2.15),
                    child: Text(
                      'Ошибка загрузки. Проверьте подключение к сети и дождитесь загрузки страницы',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700]),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
